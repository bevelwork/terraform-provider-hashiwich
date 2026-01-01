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
var _ resource.Resource = &CrackerResource{}
var _ resource.ResourceWithImportState = &CrackerResource{}

func NewCrackerResource() resource.Resource {
	return &CrackerResource{}
}

// CrackerResource defines the resource implementation.
type CrackerResource struct {
	client *ProviderConfig
}

// CrackerResourceModel describes the resource data model.
type CrackerResourceModel struct {
	Description types.String `tfsdk:"description"`
	Kind        types.String `tfsdk:"kind"`
	Quantity    types.Number `tfsdk:"quantity"`
	Price       types.Number `tfsdk:"price"`
	Id          types.String `tfsdk:"id"`
}

func (r *CrackerResource) Metadata(ctx context.Context, req resource.MetadataRequest, resp *resource.MetadataResponse) {
	resp.TypeName = req.ProviderTypeName + "_cracker"
}

func (r *CrackerResource) Schema(ctx context.Context, req resource.SchemaRequest, resp *resource.SchemaResponse) {
	resp.Schema = schema.Schema{
		MarkdownDescription: "Mock cracker resource for instructional purposes",

		Attributes: map[string]schema.Attribute{
			"description": schema.StringAttribute{
				MarkdownDescription: "A description of the cracker resource",
				Optional:            true,
			},
			"kind": schema.StringAttribute{
				MarkdownDescription: "The kind of crackers (e.g., saltine, oyster, graham)",
				Required:            true,
			},
			"quantity": schema.NumberAttribute{
				MarkdownDescription: "The number of cracker packs",
				Required:            true,
			},
			"price": schema.NumberAttribute{
				Computed:            true,
				MarkdownDescription: "The price of the crackers in dollars (hardcoded to $0.50 per pack)",
			},
			"id": schema.StringAttribute{
				Computed:            true,
				MarkdownDescription: "Cracker identifier",
				PlanModifiers: []planmodifier.String{
					stringplanmodifier.UseStateForUnknown(),
				},
			},
		},
	}
}

func (r *CrackerResource) Configure(ctx context.Context, req resource.ConfigureRequest, resp *resource.ConfigureResponse) {
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

func (r *CrackerResource) Create(ctx context.Context, req resource.CreateRequest, resp *resource.CreateResponse) {
	var data CrackerResourceModel

	// Read Terraform plan data into the model
	resp.Diagnostics.Append(req.Plan.Get(ctx, &data)...)

	if resp.Diagnostics.HasError() {
		return
	}

	// Simulate API delay

	// Calculate base price: $0.50 per pack, then apply upcharge
	quantity := data.Quantity.ValueBigFloat()
	pricePerPack := big.NewFloat(0.50)
	var basePrice big.Float
	basePrice.Mul(quantity, pricePerPack)
	finalPrice := ApplyUpcharge(&basePrice, r.client.Upcharge)
	data.Price = types.NumberValue(finalPrice)

	// Mock resource creation - generate a fake ID based on the kind
	id := fmt.Sprintf("cracker-%s-%d", data.Kind.ValueString(), len(data.Kind.ValueString()))
	data.Id = types.StringValue(id)

	tflog.Trace(ctx, "created a cracker resource", map[string]any{
		"id":       data.Id.ValueString(),
		"kind":     data.Kind.ValueString(),
		"quantity": data.Quantity.ValueBigFloat().String(),
	})

	// Save data into Terraform state
	resp.Diagnostics.Append(resp.State.Set(ctx, &data)...)
}

func (r *CrackerResource) Read(ctx context.Context, req resource.ReadRequest, resp *resource.ReadResponse) {
	var data CrackerResourceModel

	// Read Terraform prior state data into the model
	resp.Diagnostics.Append(req.State.Get(ctx, &data)...)

	if resp.Diagnostics.HasError() {
		return
	}

	// Simulate API delay

	// Recalculate price based on quantity
	quantity := data.Quantity.ValueBigFloat()
	pricePerPack := big.NewFloat(0.50)
	var totalPrice big.Float
	totalPrice.Mul(quantity, pricePerPack)
	data.Price = types.NumberValue(&totalPrice)

	// Mock resource read - just return the existing state
	// In a real implementation, this would fetch from an API

	// Save updated data into Terraform state
	resp.Diagnostics.Append(resp.State.Set(ctx, &data)...)
}

func (r *CrackerResource) Update(ctx context.Context, req resource.UpdateRequest, resp *resource.UpdateResponse) {
	var data CrackerResourceModel

	// Read Terraform plan data into the model
	resp.Diagnostics.Append(req.Plan.Get(ctx, &data)...)

	if resp.Diagnostics.HasError() {
		return
	}

	// Simulate API delay

	// Recalculate price based on quantity
	quantity := data.Quantity.ValueBigFloat()
	pricePerPack := big.NewFloat(0.50)
	var totalPrice big.Float
	totalPrice.Mul(quantity, pricePerPack)
	data.Price = types.NumberValue(&totalPrice)

	// Mock resource update - regenerate ID if kind or quantity changed
	var state CrackerResourceModel
	resp.Diagnostics.Append(req.State.Get(ctx, &state)...)
	if resp.Diagnostics.HasError() {
		return
	}

	// If kind changed, regenerate ID
	if !data.Kind.Equal(state.Kind) {
		id := fmt.Sprintf("cracker-%s-%d", data.Kind.ValueString(), len(data.Kind.ValueString()))
		data.Id = types.StringValue(id)
	} else {
		// Keep existing ID
		data.Id = state.Id
	}

	// Save updated data into Terraform state
	resp.Diagnostics.Append(resp.State.Set(ctx, &data)...)
}

func (r *CrackerResource) Delete(ctx context.Context, req resource.DeleteRequest, resp *resource.DeleteResponse) {
	var data CrackerResourceModel

	// Read Terraform prior state data into the model
	resp.Diagnostics.Append(req.State.Get(ctx, &data)...)

	if resp.Diagnostics.HasError() {
		return
	}

	// Simulate API delay

	// Mock resource deletion - nothing to do
	tflog.Trace(ctx, "deleted a cracker resource", map[string]any{
		"id": data.Id.ValueString(),
	})
}

func (r *CrackerResource) ImportState(ctx context.Context, req resource.ImportStateRequest, resp *resource.ImportStateResponse) {
	resource.ImportStatePassthroughID(ctx, path.Root("id"), req, resp)
}
