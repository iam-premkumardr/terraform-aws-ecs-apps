<!-- GETTING STARTED -->
## Getting Started

This is an example of how you may give instructions on setting up your project locally.
To get a local copy up and running follow these simple example steps.

### Prerequisites

This is one time activity and you need to do it everytime.

This is an example of how to list things you need to use the terraform module and how to install them.

Install Terraform locally using the link https://developer.hashicorp.com/terraform/install

Preferablly binary download and extract it to c:\Program Files\Terraform

Open the powershell in admin mode and run the below command

```sh
# Set $installPath to location of Terraform executable
$installPath = "C:\Program Files\Terraform"
# Save current value of PATH
$currentPath = (Get-Item -path "HKCU:\Environment" ).GetValue('Path', '', 'DoNotExpandEnvironmentNames')
# Add $installPath to $currentPath, saved as $newPath
$newPath = $currentPath + ";$installPath"
# Set PATH environment variable to $newPath value
setx PATH ($newPath)
   ```

Verify the installation
  ```sh
 terraform -help
   ```

Configure the aws login
 ```sh
 aws configure
   ```
### Installation

1. Initialise the terraform module 
 ```sh
 terraform init
   ```

2. Plan and check the terraform module 
 ```sh
 terraform plan
   ```
3. Apply the terraform module 
 ```sh
 terraform apply -auto-approve
   ```
<!-- USAGE EXAMPLES -->
## Usage

Use this space to show useful examples of how a project can be used. Additional screenshots, code examples and demos work well in this space. You may also link to more resources.

_For more examples, please refer to the [Documentation](https://developer.hashicorp.com/terraform/tutorials)_

<p align="right">(<a href="#readme-top">back to top</a>)</p>