# terraform-aws-eks 
## Origin
We forked this repository from here: https://github.com/terraform-aws-modules/terraform-aws-eks

Find the original readme [here](https://github.com/terraform-aws-modules/terraform-aws-eks)

## Let's get started
Before we can start creating an EKS you will need to add some stuff in the variables.tf file.
Check & change:
- [ ] Region
- [ ] Account ID
- [ ] Cluster Name (small letters, all togteher)
- [ ] Your Name (small letters, all togteher)
- [ ] Your role ARN & user name
- [ ] Additional User (if needed)

Everything changed to your preferences? Then go ahead by run
```
terraform init
```
This will check for dependencies and download them e.g. the module for a VPC and EKS.
With the plan command you then can see what will be created.
```
terraform plan
```
And finally you can deploy it, apply is more or less the same like plan, but you can approve the ressource creation by typing `yes`.
```
terraform apply
yes
```


After our workshop it is recommended to delete your cluster:
```
terraform destroy
```
