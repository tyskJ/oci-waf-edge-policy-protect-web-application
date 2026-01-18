=====================================================================
デプロイ - Terraform -
=====================================================================

前提条件
=====================================================================
* ``manage all-resources IN TENANCY`` を付与した IAM グループに所属する IAM ユーザーが作成されていること
* 実作業は *oci* フォルダ配下で実施すること
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

6. Edge Policy CNAME 登録
---------------------------------------------------------------------

.. note::
  
  デプロイすると、output に Edge Policy の CNAME の値が出力されるので Route 53 に登録します


* レコード登録用の json ファイルを作成 ( *oci* フォルダ配下に作成すること )

.. code-block:: bash

  cat <<EOF> recordset_create.json
  {
    "Comment": "CREATE Edge Policy CNAME record",
    "Changes": [
      {
        "Action": "CREATE",
        "ResourceRecordSet": {
          "Name": "Edge Policy 作成時に Primary domain に指定した FQDN",
          "Type": "CNAME",
          "TTL": 10,
          "ResourceRecords": [
            {
              "Value": "Edge Policy 作成時に出力された CNAME の値"
            }
          ]
        }
      }
    ]
  }
  EOF

* Route 53 に登録

.. code-block::

  aws route53 change-resource-record-sets \
  --hosted-zone-id 対象Route53のパブリックホストゾーンID \
  --change-batch file://recordset_create.json \
  --profile admin

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

3. Edge Policy CNAME 削除
---------------------------------------------------------------------

* レコード削除用の json ファイルを作成 ( *oci* フォルダ配下に作成すること )

.. code-block:: bash

  cat <<EOF> recordset_delete.json
  {
    "Comment": "DELETE Edge Policy CNAME record",
    "Changes": [
      {
        "Action": "DELETE",
        "ResourceRecordSet": {
          "Name": "Edge Policy 作成時に Primary domain に指定した FQDN",
          "Type": "CNAME",
          "TTL": 10,
          "ResourceRecords": [
            {
              "Value": "Edge Policy 作成時に出力された CNAME の値"
            }
          ]
        }
      }
    ]
  }
  EOF

* Route 53 から削除

.. code-block::

  aws route53 change-resource-record-sets \
  --hosted-zone-id 対象Route53のパブリックホストゾーンID \
  --change-batch file://recordset_delete.json \
  --profile admin



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