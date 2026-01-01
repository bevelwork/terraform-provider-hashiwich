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
var _ resource.Resource = &NapkinResource{}
var _ resource.ResourceWithImportState = &NapkinResource{}

func NewNapkinResource() resource.Resource {
	return &NapkinResource{}
}

// NapkinResource defines the resource implementation.
type NapkinResource struct {
	client *ProviderConfig
}

// NapkinResourceModel describes the resource data model.
type NapkinResourceModel struct {
	Description types.String `tfsdk:"description"`
	Quantity    types.Number `tfsdk:"quantity"`
	Price       types.Number `tfsdk:"price"`
	Id          types.String `tfsdk:"id"`
}

func (r *NapkinResource) Metadata(ctx context.Context, req resource.MetadataRequest, resp *resource.MetadataResponse) {
	resp.TypeName = req.ProviderTypeName + "_napkin"
}

func (r *NapkinResource) Schema(ctx context.Context, req resource.SchemaRequest, resp *resource.SchemaResponse) {
	resp.Schema = schema.Schema{
		MarkdownDescription: "Mock napkin resource for instructional purposes",

		Attributes: map[string]schema.Attribute{
			"description": schema.StringAttribute{
				MarkdownDescription: "A description of the napkin resource",
				Optional:            true,
			},
			"quantity": schema.NumberAttribute{
				MarkdownDescription: "The number of napkins",
				Required:            true,
			},
			"price": schema.NumberAttribute{
				Computed:            true,
				MarkdownDescription: "The price of the napkins in dollars (hardcoded to $0.25 per napkin)",
			},
			"id": schema.StringAttribute{
				Computed:            true,
				MarkdownDescription: "Napkin identifier",
				PlanModifiers: []planmodifier.String{
					stringplanmodifier.UseStateForUnknown(),
				},
			},
		},
	}
}

func (r *NapkinResource) Configure(ctx context.Context, req resource.ConfigureRequest, resp *resource.ConfigureResponse) {
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

func (r *NapkinResource) Create(ctx context.Context, req resource.CreateRequest, resp *resource.CreateResponse) {
	var data NapkinResourceModel

	// Read Terraform plan data into the model
	resp.Diagnostics.Append(req.Plan.Get(ctx, &data)...)

	if resp.Diagnostics.HasError() {
		return
	}

	// Simulate API delay

	// Calculate base price: $0.25 per napkin, then apply upcharge
	quantity := data.Quantity.ValueBigFloat()
	pricePerNapkin := big.NewFloat(0.25)
	var basePrice big.Float
	basePrice.Mul(quantity, pricePerNapkin)
	finalPrice := ApplyUpcharge(&basePrice, r.client.Upcharge)
	data.Price = types.NumberValue(finalPrice)

	// Mock resource creation - generate a fake ID
	id := fmt.Sprintf("napkin-qty-%s", quantity.Text('f', 0))
	data.Id = types.StringValue(id)

	tflog.Trace(ctx, "created a napkin resource", map[string]any{
		"id":       data.Id.ValueString(),
		"quantity": data.Quantity.ValueBigFloat().String(),
	})

	// Save data into Terraform state
	resp.Diagnostics.Append(resp.State.Set(ctx, &data)...)
}

func (r *NapkinResource) Read(ctx context.Context, req resource.ReadRequest, resp *resource.ReadResponse) {
	var data NapkinResourceModel

	// Read Terraform prior state data into the model
	resp.Diagnostics.Append(req.State.Get(ctx, &data)...)

	if resp.Diagnostics.HasError() {
		return
	}

	// Simulate API delay

	// Recalculate price based on quantity
	quantity := data.Quantity.ValueBigFloat()
	pricePerNapkin := big.NewFloat(0.25)
	var totalPrice big.Float
	totalPrice.Mul(quantity, pricePerNapkin)
	data.Price = types.NumberValue(&totalPrice)

	// Mock resource read - just return the existing state
	// In a real implementation, this would fetch from an API

	// Save updated data into Terraform state
	resp.Diagnostics.Append(resp.State.Set(ctx, &data)...)
}

func (r *NapkinResource) Update(ctx context.Context, req resource.UpdateRequest, resp *resource.UpdateResponse) {
	var data NapkinResourceModel

	// Read Terraform plan data into the model
	resp.Diagnostics.Append(req.Plan.Get(ctx, &data)...)

	if resp.Diagnostics.HasError() {
		return
	}

	// Simulate API delay

	// Recalculate price based on quantity
	quantity := data.Quantity.ValueBigFloat()
	pricePerNapkin := big.NewFloat(0.25)
	var totalPrice big.Float
	totalPrice.Mul(quantity, pricePerNapkin)
	data.Price = types.NumberValue(&totalPrice)

	// Mock resource update
	var state NapkinResourceModel
	resp.Diagnostics.Append(req.State.Get(ctx, &state)...)
	if resp.Diagnostics.HasError() {
		return
	}

	// Keep existing ID unless quantity changed significantly
	if !data.Quantity.Equal(state.Quantity) {
		id := fmt.Sprintf("napkin-qty-%s", quantity.Text('f', 0))
		data.Id = types.StringValue(id)
	} else {
		data.Id = state.Id
	}

	// Save updated data into Terraform state
	resp.Diagnostics.Append(resp.State.Set(ctx, &data)...)
}

func (r *NapkinResource) Delete(ctx context.Context, req resource.DeleteRequest, resp *resource.DeleteResponse) {
	var data NapkinResourceModel

	// Read Terraform prior state data into the model
	resp.Diagnostics.Append(req.State.Get(ctx, &data)...)

	if resp.Diagnostics.HasError() {
		return
	}

	// Simulate API delay

	// Mock resource deletion - nothing to do
	tflog.Trace(ctx, "deleted a napkin resource", map[string]any{
		"id": data.Id.ValueString(),
	})
}

func (r *NapkinResource) ImportState(ctx context.Context, req resource.ImportStateRequest, resp *resource.ImportStateResponse) {
	resource.ImportStatePassthroughID(ctx, path.Root("id"), req, resp)
}
