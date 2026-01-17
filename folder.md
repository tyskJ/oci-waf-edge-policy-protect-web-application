# フォルダ構成

- フォルダ構成は以下の通り

```
.
└── envs
    ├── aws
    │   ├── backend.tf              tfstateファイル管理定義ファイル
    │   ├── data.tf                 外部データソース定義ファイル
    │   ├── ec2.tf                  EC2定義ファイル
    │   ├── locals.tf               ローカル変数定義ファイル
    │   ├── outputs.tf              リソース戻り値定義ファイル
    │   ├── providers.tf            プロバイダー定義ファイル
    │   ├── route53.tf              Route 53定義ファイル
    │   ├── self-singned-cert.tf    自己署名証明書定義ファイル
    │   ├── userdata
    │   │   └── linux_init.sh       Linux用userdataスクリプト
    │   ├── variables.tf            変数定義ファイル
    │   ├── versions.tf             Terraformバージョン定義ファイル
    │   └── vpc.tf                  VPC定義ファイル
    └── oci
        ├── backend.tf              tfstateファイル管理定義ファイル
        ├── compartments.tf         デプロイ用コンパートメント定義ファイル
        ├── data.tf                 外部データソース定義ファイル
        ├── locals.tf               ローカル変数定義ファイル
        ├── outputs.tf              リソース戻り値定義ファイル
        ├── providers.tf            プロバイダー定義ファイル
        ├── tags.tf                 デフォルトタグ定義ファイル
        ├── variables.tf            変数定義ファイル
        ├── versions.tf             Terraformバージョン定義ファイル
        └── waf.tf                  OCI WAF定義ファイル
```