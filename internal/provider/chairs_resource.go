package provider

import (
	"context"
	"fmt"
	"math/big"

	"github.com/hashicorp/terraform-plugin-framework/path"
	"github.com/hashicorp/terraform-plugin-framework/resource"
	"github.com/hashicorp/terraform-plugin-framework/resource/schema"
	"github.com/hashicorp/terraform-plugin-framework/resource/schema/numberplanmodifier"
	"github.com/hashicorp/terraform-plugin-framework/resource/schema/planmodifier"
	"github.com/hashicorp/terraform-plugin-framework/resource/schema/stringplanmodifier"
	"github.com/hashicorp/terraform-plugin-framework/types"
	"github.com/hashicorp/terraform-plugin-log/tflog"
)

var _ resource.Resource = &ChairsResource{}
var _ resource.ResourceWithImportState = &ChairsResource{}

func NewChairsResource() resource.Resource {
	return &ChairsResource{}
}

type ChairsResource struct {
	client *ProviderConfig
}

type ChairsResourceModel struct {
	Quantity    types.Number `tfsdk:"quantity"`
	Style       types.String `tfsdk:"style"`
	Description types.String `tfsdk:"description"`
	Cost        types.Number `tfsdk:"cost"`
	Id          types.String `tfsdk:"id"`
}

func (r *ChairsResource) Metadata(ctx context.Context, req resource.MetadataRequest, resp *resource.MetadataResponse) {
	resp.TypeName = req.ProviderTypeName + "_chairs"
}

func (r *ChairsResource) Schema(ctx context.Context, req resource.SchemaRequest, resp *resource.SchemaResponse) {
	resp.Schema = schema.Schema{
		MarkdownDescription: `Comfortable seating that complements your tables, demonstrating style-based pricing and quantity management. Learn how different resource attributes affect cost while ensuring your customers have a pleasant dining experience.

*Seats await guests,*
*Comfort in every style,*
*Rest for weary feet.*`,

		Attributes: map[string]schema.Attribute{
			"quantity": schema.NumberAttribute{
				MarkdownDescription: "Number of chairs",
				Required:            true,
			},
			"style": schema.StringAttribute{
				MarkdownDescription: "Style of chairs (basic=$20/chair, comfortable=$35/chair, premium=$50/chair)",
				Required:            true,
			},
			"description": schema.StringAttribute{
				MarkdownDescription: "Description of the chairs",
				Optional:            true,
			},
			"cost": schema.NumberAttribute{
				Computed:            true,
				MarkdownDescription: "Total cost in dollars",
				PlanModifiers: []planmodifier.Number{
					numberplanmodifier.UseStateForUnknown(),
				},
			},
			"id": schema.StringAttribute{
				Computed:            true,
				MarkdownDescription: "Chairs identifier",
				PlanModifiers: []planmodifier.String{
					stringplanmodifier.UseStateForUnknown(),
				},
			},
		},
	}
}

func (r *ChairsResource) Configure(ctx context.Context, req resource.ConfigureRequest, resp *resource.ConfigureResponse) {
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

func (r *ChairsResource) Create(ctx context.Context, req resource.CreateRequest, resp *resource.CreateResponse) {
	var data ChairsResourceModel

	resp.Diagnostics.Append(req.Plan.Get(ctx, &data)...)
	if resp.Diagnostics.HasError() {
		return
	}


	// Calculate cost per chair based on style
	var costPerChair *big.Float
	style := data.Style.ValueString()
	switch style {
	case "basic":
		costPerChair = big.NewFloat(20.00)
	case "comfortable":
		costPerChair = big.NewFloat(35.00)
	case "premium":
		costPerChair = big.NewFloat(50.00)
	default:
		costPerChair = big.NewFloat(20.00) // default to basic
	}

	// Calculate total cost
	quantity := data.Quantity.ValueBigFloat()
	var totalCost big.Float
	totalCost.Mul(quantity, costPerChair)
	finalCost := ApplyUpcharge(&totalCost, r.client.Upcharge)
	data.Cost = types.NumberValue(finalCost)

	id := fmt.Sprintf("chairs-%s-%d", style, len(style))
	data.Id = types.StringValue(id)

	tflog.Trace(ctx, "created a chairs resource", map[string]any{
		"id":    data.Id.ValueString(),
		"quantity": quantity.String(),
		"style": style,
		"cost":  data.Cost.ValueBigFloat().String(),
	})

	resp.Diagnostics.Append(resp.State.Set(ctx, &data)...)
}

func (r *ChairsResource) Read(ctx context.Context, req resource.ReadRequest, resp *resource.ReadResponse) {
	var data ChairsResourceModel

	resp.Diagnostics.Append(req.State.Get(ctx, &data)...)
	if resp.Diagnostics.HasError() {
		return
	}


	// Recalculate cost
	var costPerChair *big.Float
	style := data.Style.ValueString()
	switch style {
	case "basic":
		costPerChair = big.NewFloat(20.00)
	case "comfortable":
		costPerChair = big.NewFloat(35.00)
	case "premium":
		costPerChair = big.NewFloat(50.00)
	default:
		costPerChair = big.NewFloat(20.00)
	}

	quantity := data.Quantity.ValueBigFloat()
	var totalCost big.Float
	totalCost.Mul(quantity, costPerChair)
	finalCost := ApplyUpcharge(&totalCost, r.client.Upcharge)
	data.Cost = types.NumberValue(finalCost)

	resp.Diagnostics.Append(resp.State.Set(ctx, &data)...)
}

func (r *ChairsResource) Update(ctx context.Context, req resource.UpdateRequest, resp *resource.UpdateResponse) {
	var data ChairsResourceModel

	resp.Diagnostics.Append(req.Plan.Get(ctx, &data)...)
	if resp.Diagnostics.HasError() {
		return
	}


	// Recalculate cost
	var costPerChair *big.Float
	style := data.Style.ValueString()
	switch style {
	case "basic":
		costPerChair = big.NewFloat(20.00)
	case "comfortable":
		costPerChair = big.NewFloat(35.00)
	case "premium":
		costPerChair = big.NewFloat(50.00)
	default:
		costPerChair = big.NewFloat(20.00)
	}

	quantity := data.Quantity.ValueBigFloat()
	var totalCost big.Float
	totalCost.Mul(quantity, costPerChair)
	finalCost := ApplyUpcharge(&totalCost, r.client.Upcharge)
	data.Cost = types.NumberValue(finalCost)

	var state ChairsResourceModel
	resp.Diagnostics.Append(req.State.Get(ctx, &state)...)
	if resp.Diagnostics.HasError() {
		return
	}

	if !data.Style.Equal(state.Style) {
		id := fmt.Sprintf("chairs-%s-%d", style, len(style))
		data.Id = types.StringValue(id)
	} else {
		data.Id = state.Id
	}

	resp.Diagnostics.Append(resp.State.Set(ctx, &data)...)
}

func (r *ChairsResource) Delete(ctx context.Context, req resource.DeleteRequest, resp *resource.DeleteResponse) {
	var data ChairsResourceModel

	resp.Diagnostics.Append(req.State.Get(ctx, &data)...)
	if resp.Diagnostics.HasError() {
		return
	}


	tflog.Trace(ctx, "deleted a chairs resource", map[string]any{
		"id": data.Id.ValueString(),
	})
}

func (r *ChairsResource) ImportState(ctx context.Context, req resource.ImportStateRequest, resp *resource.ImportStateResponse) {
	resource.ImportStatePassthroughID(ctx, path.Root("id"), req, resp)
}
