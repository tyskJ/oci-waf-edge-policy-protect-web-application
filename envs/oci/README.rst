=====================================================================
デプロイ - Terraform -
=====================================================================

前提条件
=====================================================================
* ``manage all-resources IN TENANCY`` を付与した IAM グループに所属する IAM ユーザーが作成されていること
* 実作業は *oci* フォルダ配下の各環境フォルダで実施すること
* 以下コマンドを実行し、*ADMIN* プロファイルを作成していること (デフォルトリージョンは *ap-tokyo-1* )

.. code-block:: bash

  oci session authenticate

事前作業(1)
=====================================================================
1. 各種モジュールインストール
---------------------------------------------------------------------
* `GitHub <https://github.com/tyskJ/common-environment-setup>`_ を参照

事前作業(2)
=====================================================================
1. *tfstate* 用バケット作成
---------------------------------------------------------------------
.. code-block:: bash

  oci os bucket create \
  --compartment-id <ルートコンパートメントOCID> \
  --name terraform-working \
  --profile ADMIN --auth security_token

.. note::

  * バケット名は、テナンシかつリージョン内で一意であれば作成できます


実作業 - ローカル -
=====================================================================
1. *backend* 用設定ファイル作成
---------------------------------------------------------------------

.. note::

  * *oci* フォルダ配下に作成すること

.. code-block:: bash

  cat <<EOF > config.oci.tfbackend
  bucket = "terraform-working"
  namespace = "テナンシに一意に付与されたネームスペース"
  key = "oci-waf-edge-policy-protect-web-application/terraform.tfstate"
  auth = "SecurityToken"
  config_file_profile = "ADMIN"
  region = "ap-tokyo-1"
  EOF

2. 変数ファイル作成
---------------------------------------------------------------------

.. note::

  * *oci* フォルダ配下に作成すること

.. code-block:: bash

  cat <<EOF > oci.auto.tfvars
  tenancy_ocid = "テナンシOCID(=ルートコンパートメントOCID)"
  domain_name = "ドメイン名"
  EOF


3. *Terraform* 初期化
---------------------------------------------------------------------
.. code-block:: bash

  terraform init -backend-config="./config.oci.tfbackend"

4. 事前確認
---------------------------------------------------------------------
.. code-block:: bash

  terraform plan

5. デプロイ
---------------------------------------------------------------------
.. code-block:: bash

  terraform apply --auto-approve

後片付け - ローカル -
=====================================================================
1. 環境削除
---------------------------------------------------------------------
.. code-block:: bash

  terraform destroy --auto-approve

2. *tfstate* 用S3バケット削除
---------------------------------------------------------------------
.. code-block:: bash

  oci os bucket delete \
  --bucket-name terraform-working \
  --force --empty \
  --profile ADMIN --auth security_token


番外編
=====================================================================
コンパートメント削除失敗
---------------------------------------------------------------------
* コンパートメント削除に失敗する場合、対象コンパートメントに属するリソースが存在することが原因です
* その場合、以下コマンドを実行し存在するリソース一覧を確認し削除してください

.. code-block:: bash

  oci search resource structured-search \
  --query-text "query all resources where compartmentId = 'コンパートメントOCID'"

.. note::

  * コンパートメントOCIDは、適宜調査対象の値に置き換えてください