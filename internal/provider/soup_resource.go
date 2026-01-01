package provider

import (
	"context"
	"fmt"
	"math/big"

	"github.com/hashicorp/terraform-plugin-framework/path"
	"github.com/hashicorp/terraform-plugin-framework/resource"
	"github.com/hashicorp/terraform-plugin-framework/resource/schema"
	"github.com/hashicorp/terraform-plugin-framework/resource/schema/planmodifier"
	"github.com/hashicorp/terraform-plugin-framework/resource/schema/stringplanmodifier"
	"github.com/hashicorp/terraform-plugin-framework/types"
	"github.com/hashicorp/terraform-plugin-log/tflog"
)

// Ensure provider defined types fully satisfy framework interfaces.
var _ resource.Resource = &SoupResource{}
var _ resource.ResourceWithImportState = &SoupResource{}

func NewSoupResource() resource.Resource {
	return &SoupResource{}
}

// SoupResource defines the resource implementation.
type SoupResource struct {
	client *ProviderConfig
}

// SoupResourceModel describes the resource data model.
type SoupResourceModel struct {
	Description types.String `tfsdk:"description"`
	Kind        types.String `tfsdk:"kind"`
	Temperature types.String `tfsdk:"temperature"`
	Price       types.Number `tfsdk:"price"`
	Id          types.String `tfsdk:"id"`
}

func (r *SoupResource) Metadata(ctx context.Context, req resource.MetadataRequest, resp *resource.MetadataResponse) {
	resp.TypeName = req.ProviderTypeName + "_soup"
}

func (r *SoupResource) Schema(ctx context.Context, req resource.SchemaRequest, resp *resource.SchemaResponse) {
	resp.Schema = schema.Schema{
		MarkdownDescription: `A comforting bowl of warmth that demonstrates string attributes and computed values. Perfect for learning Terraform basics while imagining a cozy meal on a chilly day.

**Example Usage:**

` + "```hcl" + `
# Hot soup example
resource "hw_soup" "tomato_soup" {
  kind        = "tomato"
  temperature = "hot"
  description = "Classic tomato soup"
}

# Cold soup example
resource "hw_soup" "gazpacho" {
  kind        = "gazpacho"
  temperature = "cold"
  description = "Chilled Spanish gazpacho"
}

# Using for_each to create multiple soups
variable "soup_menu" {
  type = map(object({
    kind        = string
    temperature = string
  }))
  default = {
    chicken_noodle = {
      kind        = "chicken noodle"
      temperature = "hot"
    }
    vegetable = {
      kind        = "vegetable"
      temperature = "hot"
    }
    vichyssoise = {
      kind        = "vichyssoise"
      temperature = "cold"
    }
  }
}

resource "hw_soup" "menu" {
  for_each = var.soup_menu
  
  kind        = each.value.kind
  temperature = each.value.temperature
  description = "${each.value.kind} soup (${each.value.temperature})"
}
` + "```" + `

**Key Concepts:**
- Demonstrates **string attributes** for kind and temperature
- Shows **computed price** attribute (always $2.50)
- Useful for learning basic resource structure
- Temperature must be "hot" or "cold"

*Steam rises gently,*
*Bowl of warmth in cold hands,*
*Comfort in each spoon.*`,

		Attributes: map[string]schema.Attribute{
			"description": schema.StringAttribute{
				MarkdownDescription: "A description of the soup resource",
				Optional:            true,
			},
			"kind": schema.StringAttribute{
				MarkdownDescription: "The kind of soup (e.g., tomato, chicken noodle, vegetable)",
				Required:            true,
			},
			"temperature": schema.StringAttribute{
				MarkdownDescription: "The temperature of the soup (hot or cold)",
				Required:            true,
			},
			"price": schema.NumberAttribute{
				Computed:            true,
				MarkdownDescription: "The price of the soup in dollars (hardcoded to $2.50)",
			},
			"id": schema.StringAttribute{
				Computed:            true,
				MarkdownDescription: "Soup identifier",
				PlanModifiers: []planmodifier.String{
					stringplanmodifier.UseStateForUnknown(),
				},
			},
		},
	}
}

func (r *SoupResource) Configure(ctx context.Context, req resource.ConfigureRequest, resp *resource.ConfigureResponse) {
	// Prevent panic if the provider has not been configured.
	if req.ProviderData == nil {
		return
	}

	config, ok := req.ProviderData.(*ProviderConfig)
	if !ok {
		resp.Diagnostics.AddError(
			"Unexpected Provider Data Type",
			"Expected *ProviderConfig, got something else",
		)
		return
	}

	r.client = config
}

func (r *SoupResource) Create(ctx context.Context, req resource.CreateRequest, resp *resource.CreateResponse) {
	var data SoupResourceModel

	// Read Terraform plan data into the model
	resp.Diagnostics.Append(req.Plan.Get(ctx, &data)...)

	if resp.Diagnostics.HasError() {
		return
	}

	// Simulate API delay

	// Set base price: $2.50, then apply upcharge
	basePrice := big.NewFloat(2.50)
	finalPrice := ApplyUpcharge(basePrice, r.client.Upcharge)
	data.Price = types.NumberValue(finalPrice)

	// Mock resource creation - generate a fake ID based on the kind
	id := fmt.Sprintf("soup-%s-%d", data.Kind.ValueString(), len(data.Kind.ValueString()))
	data.Id = types.StringValue(id)

	tflog.Trace(ctx, "created a soup resource", map[string]any{
		"id":          data.Id.ValueString(),
		"kind":        data.Kind.ValueString(),
		"temperature": data.Temperature.ValueString(),
	})

	// Save data into Terraform state
	resp.Diagnostics.Append(resp.State.Set(ctx, &data)...)
}

func (r *SoupResource) Read(ctx context.Context, req resource.ReadRequest, resp *resource.ReadResponse) {
	var data SoupResourceModel

	// Read Terraform prior state data into the model
	resp.Diagnostics.Append(req.State.Get(ctx, &data)...)

	if resp.Diagnostics.HasError() {
		return
	}

	// Simulate API delay

	// Ensure price is set (in case it wasn't in state)
	data.Price = types.NumberValue(big.NewFloat(2.50))

	// Mock resource read - just return the existing state
	// In a real implementation, this would fetch from an API

	// Save updated data into Terraform state
	resp.Diagnostics.Append(resp.State.Set(ctx, &data)...)
}

func (r *SoupResource) Update(ctx context.Context, req resource.UpdateRequest, resp *resource.UpdateResponse) {
	var data SoupResourceModel

	// Read Terraform plan data into the model
	resp.Diagnostics.Append(req.Plan.Get(ctx, &data)...)

	if resp.Diagnostics.HasError() {
		return
	}

	// Simulate API delay

	// Ensure price is always set to $2.50
	data.Price = types.NumberValue(big.NewFloat(2.50))

	// Mock resource update - regenerate ID if kind changed
	var state SoupResourceModel
	resp.Diagnostics.Append(req.State.Get(ctx, &state)...)
	if resp.Diagnostics.HasError() {
		return
	}

	// If kind changed, regenerate ID
	if !data.Kind.Equal(state.Kind) {
		id := fmt.Sprintf("soup-%s-%d", data.Kind.ValueString(), len(data.Kind.ValueString()))
		data.Id = types.StringValue(id)
	} else {
		// Keep existing ID
		data.Id = state.Id
	}

	// Save updated data into Terraform state
	resp.Diagnostics.Append(resp.State.Set(ctx, &data)...)
}

func (r *SoupResource) Delete(ctx context.Context, req resource.DeleteRequest, resp *resource.DeleteResponse) {
	var data SoupResourceModel

	// Read Terraform prior state data into the model
	resp.Diagnostics.Append(req.State.Get(ctx, &data)...)

	if resp.Diagnostics.HasError() {
		return
	}

	// Simulate API delay

	// Mock resource deletion - nothing to do
	tflog.Trace(ctx, "deleted a soup resource", map[string]any{
		"id": data.Id.ValueString(),
	})
}

func (r *SoupResource) ImportState(ctx context.Context, req resource.ImportStateRequest, resp *resource.ImportStateResponse) {
	resource.ImportStatePassthroughID(ctx, path.Root("id"), req, resp)
}
