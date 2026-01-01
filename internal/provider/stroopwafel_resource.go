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
var _ resource.Resource = &StroopwafelResource{}
var _ resource.ResourceWithImportState = &StroopwafelResource{}

func NewStroopwafelResource() resource.Resource {
	return &StroopwafelResource{}
}

// StroopwafelResource defines the resource implementation.
type StroopwafelResource struct {
	client *ProviderConfig
}

// StroopwafelResourceModel describes the resource data model.
type StroopwafelResourceModel struct {
	Description types.String `tfsdk:"description"`
	Kind        types.String `tfsdk:"kind"`
	Price       types.Number `tfsdk:"price"`
	Id          types.String `tfsdk:"id"`
}

func (r *StroopwafelResource) Metadata(ctx context.Context, req resource.MetadataRequest, resp *resource.MetadataResponse) {
	resp.TypeName = req.ProviderTypeName + "_stroopwafel"
}

func (r *StroopwafelResource) Schema(ctx context.Context, req resource.SchemaRequest, resp *resource.SchemaResponse) {
	resp.Schema = schema.Schema{
		MarkdownDescription: "Mock stroopwafel resource for instructional purposes",

		Attributes: map[string]schema.Attribute{
			"description": schema.StringAttribute{
				MarkdownDescription: "A description of the stroopwafel resource",
				Optional:            true,
			},
			"kind": schema.StringAttribute{
				MarkdownDescription: "The kind of stroopwafel (e.g., classic, caramel, chocolate, honey)",
				Required:            true,
			},
			"price": schema.NumberAttribute{
				Computed:            true,
				MarkdownDescription: "The price of the stroopwafel in dollars (hardcoded to $1.75)",
			},
			"id": schema.StringAttribute{
				Computed:            true,
				MarkdownDescription: "Stroopwafel identifier",
				PlanModifiers: []planmodifier.String{
					stringplanmodifier.UseStateForUnknown(),
				},
			},
		},
	}
}

func (r *StroopwafelResource) Configure(ctx context.Context, req resource.ConfigureRequest, resp *resource.ConfigureResponse) {
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

func (r *StroopwafelResource) Create(ctx context.Context, req resource.CreateRequest, resp *resource.CreateResponse) {
	var data StroopwafelResourceModel

	// Read Terraform plan data into the model
	resp.Diagnostics.Append(req.Plan.Get(ctx, &data)...)

	if resp.Diagnostics.HasError() {
		return
	}

	// Simulate API delay

	// Set base price: $1.75, then apply upcharge
	basePrice := big.NewFloat(1.75)
	finalPrice := ApplyUpcharge(basePrice, r.client.Upcharge)
	data.Price = types.NumberValue(finalPrice)

	// Mock resource creation - generate a fake ID based on the kind
	id := fmt.Sprintf("stroopwafel-%s-%d", data.Kind.ValueString(), len(data.Kind.ValueString()))
	data.Id = types.StringValue(id)

	tflog.Trace(ctx, "created a stroopwafel resource", map[string]any{
		"id":   data.Id.ValueString(),
		"kind": data.Kind.ValueString(),
	})

	// Save data into Terraform state
	resp.Diagnostics.Append(resp.State.Set(ctx, &data)...)
}

func (r *StroopwafelResource) Read(ctx context.Context, req resource.ReadRequest, resp *resource.ReadResponse) {
	var data StroopwafelResourceModel

	// Read Terraform prior state data into the model
	resp.Diagnostics.Append(req.State.Get(ctx, &data)...)

	if resp.Diagnostics.HasError() {
		return
	}

	// Simulate API delay

	// Ensure price is set (in case it wasn't in state)
	basePrice := big.NewFloat(1.75)
	finalPrice := ApplyUpcharge(basePrice, r.client.Upcharge)
	data.Price = types.NumberValue(finalPrice)

	// Mock resource read - just return the existing state
	// In a real implementation, this would fetch from an API

	// Save updated data into Terraform state
	resp.Diagnostics.Append(resp.State.Set(ctx, &data)...)
}

func (r *StroopwafelResource) Update(ctx context.Context, req resource.UpdateRequest, resp *resource.UpdateResponse) {
	var data StroopwafelResourceModel

	// Read Terraform plan data into the model
	resp.Diagnostics.Append(req.Plan.Get(ctx, &data)...)

	if resp.Diagnostics.HasError() {
		return
	}

	// Simulate API delay

	// Ensure price is always set to $1.75 + upcharge
	basePrice := big.NewFloat(1.75)
	finalPrice := ApplyUpcharge(basePrice, r.client.Upcharge)
	data.Price = types.NumberValue(finalPrice)

	// Mock resource update - regenerate ID if kind changed
	var state StroopwafelResourceModel
	resp.Diagnostics.Append(req.State.Get(ctx, &state)...)
	if resp.Diagnostics.HasError() {
		return
	}

	// If kind changed, regenerate ID
	if !data.Kind.Equal(state.Kind) {
		id := fmt.Sprintf("stroopwafel-%s-%d", data.Kind.ValueString(), len(data.Kind.ValueString()))
		data.Id = types.StringValue(id)
	} else {
		// Keep existing ID
		data.Id = state.Id
	}

	// Save updated data into Terraform state
	resp.Diagnostics.Append(resp.State.Set(ctx, &data)...)
}

func (r *StroopwafelResource) Delete(ctx context.Context, req resource.DeleteRequest, resp *resource.DeleteResponse) {
	var data StroopwafelResourceModel

	// Read Terraform prior state data into the model
	resp.Diagnostics.Append(req.State.Get(ctx, &data)...)

	if resp.Diagnostics.HasError() {
		return
	}

	// Simulate API delay

	// Mock resource deletion - nothing to do
	tflog.Trace(ctx, "deleted a stroopwafel resource", map[string]any{
		"id": data.Id.ValueString(),
	})
}

func (r *StroopwafelResource) ImportState(ctx context.Context, req resource.ImportStateRequest, resp *resource.ImportStateResponse) {
	resource.ImportStatePassthroughID(ctx, path.Root("id"), req, resp)
}
