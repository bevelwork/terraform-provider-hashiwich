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

var _ resource.Resource = &OvenResource{}
var _ resource.ResourceWithImportState = &OvenResource{}

func NewOvenResource() resource.Resource {
	return &OvenResource{}
}

type OvenResource struct {
	client *ProviderConfig
}

type OvenResourceModel struct {
	Type        types.String `tfsdk:"type"`
	Description types.String `tfsdk:"description"`
	Cost        types.Number `tfsdk:"cost"`
	Id          types.String `tfsdk:"id"`
}

func (r *OvenResource) Metadata(ctx context.Context, req resource.MetadataRequest, resp *resource.MetadataResponse) {
	resp.TypeName = req.ProviderTypeName + "_oven"
}

func (r *OvenResource) Schema(ctx context.Context, req resource.SchemaRequest, resp *resource.SchemaResponse) {
	resp.Schema = schema.Schema{
		MarkdownDescription: "Oven resource for sandwich shop. Required for hw_store.",

		Attributes: map[string]schema.Attribute{
			"type": schema.StringAttribute{
				MarkdownDescription: "Type of oven (e.g., standard, commercial, high-capacity)",
				Required:            true,
			},
			"description": schema.StringAttribute{
				MarkdownDescription: "Description of the oven",
				Optional:            true,
			},
			"cost": schema.NumberAttribute{
				Computed:            true,
				MarkdownDescription: "Cost of the oven in dollars (varies by type: standard=$500, commercial=$1200, high-capacity=$2000)",
			},
			"id": schema.StringAttribute{
				Computed:            true,
				MarkdownDescription: "Oven identifier",
				PlanModifiers: []planmodifier.String{
					stringplanmodifier.UseStateForUnknown(),
				},
			},
		},
	}
}

func (r *OvenResource) Configure(ctx context.Context, req resource.ConfigureRequest, resp *resource.ConfigureResponse) {
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

func (r *OvenResource) Create(ctx context.Context, req resource.CreateRequest, resp *resource.CreateResponse) {
	var data OvenResourceModel

	resp.Diagnostics.Append(req.Plan.Get(ctx, &data)...)
	if resp.Diagnostics.HasError() {
		return
	}


	// Calculate cost based on type
	var basePrice *big.Float
	ovenType := data.Type.ValueString()
	switch ovenType {
	case "standard":
		basePrice = big.NewFloat(500.00)
	case "commercial":
		basePrice = big.NewFloat(1200.00)
	case "high-capacity":
		basePrice = big.NewFloat(2000.00)
	default:
		basePrice = big.NewFloat(500.00) // default to standard
	}

	finalPrice := ApplyUpcharge(basePrice, r.client.Upcharge)
	data.Cost = types.NumberValue(finalPrice)

	id := fmt.Sprintf("oven-%s-%d", ovenType, len(ovenType))
	data.Id = types.StringValue(id)

	tflog.Trace(ctx, "created an oven resource", map[string]any{
		"id":   data.Id.ValueString(),
		"type": ovenType,
		"cost": data.Cost.ValueBigFloat().String(),
	})

	resp.Diagnostics.Append(resp.State.Set(ctx, &data)...)
}

func (r *OvenResource) Read(ctx context.Context, req resource.ReadRequest, resp *resource.ReadResponse) {
	var data OvenResourceModel

	resp.Diagnostics.Append(req.State.Get(ctx, &data)...)
	if resp.Diagnostics.HasError() {
		return
	}


	// Recalculate cost
	var basePrice *big.Float
	ovenType := data.Type.ValueString()
	switch ovenType {
	case "standard":
		basePrice = big.NewFloat(500.00)
	case "commercial":
		basePrice = big.NewFloat(1200.00)
	case "high-capacity":
		basePrice = big.NewFloat(2000.00)
	default:
		basePrice = big.NewFloat(500.00)
	}

	finalPrice := ApplyUpcharge(basePrice, r.client.Upcharge)
	data.Cost = types.NumberValue(finalPrice)

	resp.Diagnostics.Append(resp.State.Set(ctx, &data)...)
}

func (r *OvenResource) Update(ctx context.Context, req resource.UpdateRequest, resp *resource.UpdateResponse) {
	var data OvenResourceModel

	resp.Diagnostics.Append(req.Plan.Get(ctx, &data)...)
	if resp.Diagnostics.HasError() {
		return
	}


	// Recalculate cost
	var basePrice *big.Float
	ovenType := data.Type.ValueString()
	switch ovenType {
	case "standard":
		basePrice = big.NewFloat(500.00)
	case "commercial":
		basePrice = big.NewFloat(1200.00)
	case "high-capacity":
		basePrice = big.NewFloat(2000.00)
	default:
		basePrice = big.NewFloat(500.00)
	}

	finalPrice := ApplyUpcharge(basePrice, r.client.Upcharge)
	data.Cost = types.NumberValue(finalPrice)

	var state OvenResourceModel
	resp.Diagnostics.Append(req.State.Get(ctx, &state)...)
	if resp.Diagnostics.HasError() {
		return
	}

	if !data.Type.Equal(state.Type) {
		id := fmt.Sprintf("oven-%s-%d", ovenType, len(ovenType))
		data.Id = types.StringValue(id)
	} else {
		data.Id = state.Id
	}

	resp.Diagnostics.Append(resp.State.Set(ctx, &data)...)
}

func (r *OvenResource) Delete(ctx context.Context, req resource.DeleteRequest, resp *resource.DeleteResponse) {
	var data OvenResourceModel

	resp.Diagnostics.Append(req.State.Get(ctx, &data)...)
	if resp.Diagnostics.HasError() {
		return
	}


	tflog.Trace(ctx, "deleted an oven resource", map[string]any{
		"id": data.Id.ValueString(),
	})
}

func (r *OvenResource) ImportState(ctx context.Context, req resource.ImportStateRequest, resp *resource.ImportStateResponse) {
	resource.ImportStatePassthroughID(ctx, path.Root("id"), req, resp)
}
