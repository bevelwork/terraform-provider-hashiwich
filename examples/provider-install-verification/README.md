# Provider Install Verification

This example verifies that the provider can be installed and used correctly.

## Local Development Setup

To use the provider locally for development, you need to configure Terraform to use your locally built provider binary.

### Option 1: Using .terraformrc (Recommended)

1. Build the provider:
   ```bash
   cd /home/spiff/dev/bevel/hashiwich
   go build -o terraform-provider-hashiwich .
   ```

2. Create or update `~/.terraformrc` with the following content:
   ```
   provider_installation {
     dev_overrides {
       "registry.terraform.io/bevelwork/hashiwich" = "/home/spiff/dev/bevel/hashiwich"
     }
   }
   ```

   Note: The path should point to the directory containing the provider binary, not the binary itself.

3. Run terraform init and validate:
   ```bash
   cd examples/provider-install-verification
   terraform init
   terraform validate
   ```

### Option 2: Using TF_REATTACH_PROVIDERS (For Debug Mode)

If you want to run the provider in debug mode:

1. In one terminal, run the provider in debug mode:
   ```bash
   cd /home/spiff/dev/bevel/hashiwich
   go run main.go -debug
   ```

2. In another terminal, set the TF_REATTACH_PROVIDERS environment variable and run terraform commands.

## Troubleshooting

If you see errors about the provider not being found:
- Make sure the provider binary exists at the path specified in `.terraformrc`
- Make sure the binary is named `terraform-provider-hashiwich`
- Try running `terraform init -upgrade` to refresh provider cache
- Check that the `source` in `required_providers` matches the dev override key
