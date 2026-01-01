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
var _ resource.Resource = &CookieResource{}
var _ resource.ResourceWithImportState = &CookieResource{}

func NewCookieResource() resource.Resource {
	return &CookieResource{}
}

// CookieResource defines the resource implementation.
type CookieResource struct {
	client *ProviderConfig
}

// CookieResourceModel describes the resource data model.
type CookieResourceModel struct {
	Description types.String `tfsdk:"description"`
	Kind        types.String `tfsdk:"kind"`
	Price       types.Number `tfsdk:"price"`
	Id          types.String `tfsdk:"id"`
}

func (r *CookieResource) Metadata(ctx context.Context, req resource.MetadataRequest, resp *resource.MetadataResponse) {
	resp.TypeName = req.ProviderTypeName + "_cookie"
}

func (r *CookieResource) Schema(ctx context.Context, req resource.SchemaRequest, resp *resource.SchemaResponse) {
	resp.Schema = schema.Schema{
		MarkdownDescription: `A sweet treat resource that brings joy to any configuration. Perfect for learning simple resource management while indulging in the simple pleasures of baked goods.

*Warm from the oven,*
*Chocolate chips melting soft,*
*Sweet comfort found.*`,

		Attributes: map[string]schema.Attribute{
			"description": schema.StringAttribute{
				MarkdownDescription: "A description of the cookie resource",
				Optional:            true,
			},
			"kind": schema.StringAttribute{
				MarkdownDescription: "The kind of cookie (e.g., chocolate chip, oatmeal, sugar, snickerdoodle)",
				Required:            true,
			},
			"price": schema.NumberAttribute{
				Computed:            true,
				MarkdownDescription: "The price of the cookie in dollars (hardcoded to $1.50)",
			},
			"id": schema.StringAttribute{
				Computed:            true,
				MarkdownDescription: "Cookie identifier",
				PlanModifiers: []planmodifier.String{
					stringplanmodifier.UseStateForUnknown(),
				},
			},
		},
	}
}

func (r *CookieResource) Configure(ctx context.Context, req resource.ConfigureRequest, resp *resource.ConfigureResponse) {
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

func (r *CookieResource) Create(ctx context.Context, req resource.CreateRequest, resp *resource.CreateResponse) {
	var data CookieResourceModel

	// Read Terraform plan data into the model
	resp.Diagnostics.Append(req.Plan.Get(ctx, &data)...)

	if resp.Diagnostics.HasError() {
		return
	}

	// Simulate API delay

	// Set base price: $1.50, then apply upcharge
	basePrice := big.NewFloat(1.50)
	finalPrice := ApplyUpcharge(basePrice, r.client.Upcharge)
	data.Price = types.NumberValue(finalPrice)

	// Mock resource creation - generate a fake ID based on the kind
	id := fmt.Sprintf("cookie-%s-%d", data.Kind.ValueString(), len(data.Kind.ValueString()))
	data.Id = types.StringValue(id)

	tflog.Trace(ctx, "created a cookie resource", map[string]any{
		"id":   data.Id.ValueString(),
		"kind": data.Kind.ValueString(),
	})

	// Save data into Terraform state
	resp.Diagnostics.Append(resp.State.Set(ctx, &data)...)
}

func (r *CookieResource) Read(ctx context.Context, req resource.ReadRequest, resp *resource.ReadResponse) {
	var data CookieResourceModel

	// Read Terraform prior state data into the model
	resp.Diagnostics.Append(req.State.Get(ctx, &data)...)

	if resp.Diagnostics.HasError() {
		return
	}

	// Simulate API delay

	// Ensure price is set (in case it wasn't in state)
	basePrice := big.NewFloat(1.50)
	finalPrice := ApplyUpcharge(basePrice, r.client.Upcharge)
	data.Price = types.NumberValue(finalPrice)

	// Mock resource read - just return the existing state
	// In a real implementation, this would fetch from an API

	// Save updated data into Terraform state
	resp.Diagnostics.Append(resp.State.Set(ctx, &data)...)
}

func (r *CookieResource) Update(ctx context.Context, req resource.UpdateRequest, resp *resource.UpdateResponse) {
	var data CookieResourceModel

	// Read Terraform plan data into the model
	resp.Diagnostics.Append(req.Plan.Get(ctx, &data)...)

	if resp.Diagnostics.HasError() {
		return
	}

	// Simulate API delay

	// Ensure price is always set to $1.50 + upcharge
	basePrice := big.NewFloat(1.50)
	finalPrice := ApplyUpcharge(basePrice, r.client.Upcharge)
	data.Price = types.NumberValue(finalPrice)

	// Mock resource update - regenerate ID if kind changed
	var state CookieResourceModel
	resp.Diagnostics.Append(req.State.Get(ctx, &state)...)
	if resp.Diagnostics.HasError() {
		return
	}

	// If kind changed, regenerate ID
	if !data.Kind.Equal(state.Kind) {
		id := fmt.Sprintf("cookie-%s-%d", data.Kind.ValueString(), len(data.Kind.ValueString()))
		data.Id = types.StringValue(id)
	} else {
		// Keep existing ID
		data.Id = state.Id
	}

	// Save updated data into Terraform state
	resp.Diagnostics.Append(resp.State.Set(ctx, &data)...)
}

func (r *CookieResource) Delete(ctx context.Context, req resource.DeleteRequest, resp *resource.DeleteResponse) {
	var data CookieResourceModel

	// Read Terraform prior state data into the model
	resp.Diagnostics.Append(req.State.Get(ctx, &data)...)

	if resp.Diagnostics.HasError() {
		return
	}

	// Simulate API delay

	// Mock resource deletion - nothing to do
	tflog.Trace(ctx, "deleted a cookie resource", map[string]any{
		"id": data.Id.ValueString(),
	})
}

func (r *CookieResource) ImportState(ctx context.Context, req resource.ImportStateRequest, resp *resource.ImportStateResponse) {
	resource.ImportStatePassthroughID(ctx, path.Root("id"), req, resp)
}
