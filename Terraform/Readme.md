1.What are different artifacts you need to create - name of the artifacts and its purpose ??



2: List the tools you will to create and store the Terraform templates.

Explanation:
- We can create one storage account with storage container where we can store tf.state file as backup.
- Azure git repo where we can store Terraform template.
- Visual studio or any text editor.
- Terraform v-0.12 or can use latest  version v-0.14
- Azure key vault service to store all secret_value



3: Explain the process and steps to create automated deployment pipeline ?

Explanation:
- we can create build pipeline to just copy terraform project files into publish artifacts.Terraform project can be included with app project
and store into Azure git repo.
- We need to create one copy task after building the application code which can be copied whole terraform project into publish artifacts.
- Now publish artifact is also having terraform project which can be use in Release pipeline .
- Create Release pipeline and use the same publish artifacts to get the Terrafrom files.
    - Release 1st task to run shell script to get storage key using Azure CLI . This Key is used to authenticate
        backend storage account.
    - 2nd Task to Replace Environment token like storage account , storage key in terraform files.
    - 3rd Task to Install Terraform tool with version 0.12.3
    - 4th Task Terraform init: To initialize configuration directory where all terraform files present means publish artifact
      and we can configure storage account and container to store tf.state file.
    - 4th Task Terraform Plan: This task executes "plan" command which is translating terraform configuration into execution plan.
    - 5th Task Terraform apply: This task execute "Apply" command to create actual infrastructure based on configuration.
 4: Create a sample Terraform template you will use to deploy Below services:

 Explanation:
  1.Just use the Azure credentials and  export authentication parameter as parameter:
   $env:ARM_SUBSCRIPTION_ID = ""
   $env:ARM_CLIENT_ID = ""
   $env:ARM_CLIENT_SECRET = ""
   $env:ARM_TENANT_ID = ""
  2: Download Terraform project and go to under Terraform project and run below command:

      terraform init
      terraform plan
      terraform apply
5:Explain how will you access the password stored in Key Vault and use it as Admin Password in the VM
Terraform template.

Explanation:
 - I will use data source "azurerm_key_vault_secret" to get the store value in key vault.
 - I will provide the secret key and vault URI to get the secret value of admin password and the same password I can use at VM creation configuration:
  like this (admin_password      = "${data.azurerm_key_vault_secret.test.value}).
 - Kindly check in main.tf , I am using the same scenario.
