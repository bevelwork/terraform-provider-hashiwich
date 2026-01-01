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

var _ resource.Resource = &TablesResource{}
var _ resource.ResourceWithImportState = &TablesResource{}

func NewTablesResource() resource.Resource {
	return &TablesResource{}
}

type TablesResource struct {
	client *ProviderConfig
}

type TablesResourceModel struct {
	Quantity    types.Number `tfsdk:"quantity"`
	Size        types.String `tfsdk:"size"`
	Description types.String `tfsdk:"description"`
	Cost        types.Number `tfsdk:"cost"`
	Capacity    types.Number `tfsdk:"capacity"`
	Id          types.String `tfsdk:"id"`
}

func (r *TablesResource) Metadata(ctx context.Context, req resource.MetadataRequest, resp *resource.MetadataResponse) {
	resp.TypeName = req.ProviderTypeName + "_tables"
}

func (r *TablesResource) Schema(ctx context.Context, req resource.SchemaRequest, resp *resource.SchemaResponse) {
	resp.Schema = schema.Schema{
		MarkdownDescription: `The foundation of dining space, where customers gather to enjoy their meals. Demonstrates quantity-based resources, size variations, and capacity calculations that scale with your restaurant's needs.

*Wooden surfaces wait,*
*Ready for plates and laughter,*
*Gathering place set.*`,

		Attributes: map[string]schema.Attribute{
			"quantity": schema.NumberAttribute{
				MarkdownDescription: "Number of tables",
				Required:            true,
			},
			"size": schema.StringAttribute{
				MarkdownDescription: "Size of tables (small=2 seats, medium=4 seats, large=6 seats)",
				Required:            true,
			},
			"description": schema.StringAttribute{
				MarkdownDescription: "Description of the tables",
				Optional:            true,
			},
			"cost": schema.NumberAttribute{
				Computed:            true,
				MarkdownDescription: "Total cost in dollars (small=$50/table, medium=$100/table, large=$150/table)",
				PlanModifiers: []planmodifier.Number{
					numberplanmodifier.UseStateForUnknown(),
				},
			},
			"capacity": schema.NumberAttribute{
				Computed:            true,
				MarkdownDescription: "Total seating capacity (quantity * seats per table)",
				PlanModifiers: []planmodifier.Number{
					numberplanmodifier.UseStateForUnknown(),
				},
			},
			"id": schema.StringAttribute{
				Computed:            true,
				MarkdownDescription: "Tables identifier",
				PlanModifiers: []planmodifier.String{
					stringplanmodifier.UseStateForUnknown(),
				},
			},
		},
	}
}

func (r *TablesResource) Configure(ctx context.Context, req resource.ConfigureRequest, resp *resource.ConfigureResponse) {
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

func (r *TablesResource) Create(ctx context.Context, req resource.CreateRequest, resp *resource.CreateResponse) {
	var data TablesResourceModel

	resp.Diagnostics.Append(req.Plan.Get(ctx, &data)...)
	if resp.Diagnostics.HasError() {
		return
	}


	// Calculate cost per table based on size
	var costPerTable *big.Float
	var seatsPerTable *big.Float
	size := data.Size.ValueString()
	switch size {
	case "small":
		costPerTable = big.NewFloat(50.00)
		seatsPerTable = big.NewFloat(2.0)
	case "medium":
		costPerTable = big.NewFloat(100.00)
		seatsPerTable = big.NewFloat(4.0)
	case "large":
		costPerTable = big.NewFloat(150.00)
		seatsPerTable = big.NewFloat(6.0)
	default:
		costPerTable = big.NewFloat(50.00)
		seatsPerTable = big.NewFloat(2.0)
	}

	// Calculate total cost
	quantity := data.Quantity.ValueBigFloat()
	var totalCost big.Float
	totalCost.Mul(quantity, costPerTable)
	finalCost := ApplyUpcharge(&totalCost, r.client.Upcharge)
	data.Cost = types.NumberValue(finalCost)

	// Calculate capacity
	var totalCapacity big.Float
	totalCapacity.Mul(quantity, seatsPerTable)
	data.Capacity = types.NumberValue(&totalCapacity)

	id := fmt.Sprintf("tables-%s-%d", size, len(size))
	data.Id = types.StringValue(id)

	tflog.Trace(ctx, "created a tables resource", map[string]any{
		"id":       data.Id.ValueString(),
		"quantity": quantity.String(),
		"size":     size,
		"cost":     data.Cost.ValueBigFloat().String(),
		"capacity": data.Capacity.ValueBigFloat().String(),
	})

	resp.Diagnostics.Append(resp.State.Set(ctx, &data)...)
}

func (r *TablesResource) Read(ctx context.Context, req resource.ReadRequest, resp *resource.ReadResponse) {
	var data TablesResourceModel

	resp.Diagnostics.Append(req.State.Get(ctx, &data)...)
	if resp.Diagnostics.HasError() {
		return
	}


	// Recalculate cost and capacity
	var costPerTable *big.Float
	var seatsPerTable *big.Float
	size := data.Size.ValueString()
	switch size {
	case "small":
		costPerTable = big.NewFloat(50.00)
		seatsPerTable = big.NewFloat(2.0)
	case "medium":
		costPerTable = big.NewFloat(100.00)
		seatsPerTable = big.NewFloat(4.0)
	case "large":
		costPerTable = big.NewFloat(150.00)
		seatsPerTable = big.NewFloat(6.0)
	default:
		costPerTable = big.NewFloat(50.00)
		seatsPerTable = big.NewFloat(2.0)
	}

	quantity := data.Quantity.ValueBigFloat()
	var totalCost big.Float
	totalCost.Mul(quantity, costPerTable)
	finalCost := ApplyUpcharge(&totalCost, r.client.Upcharge)
	data.Cost = types.NumberValue(finalCost)

	var totalCapacity big.Float
	totalCapacity.Mul(quantity, seatsPerTable)
	data.Capacity = types.NumberValue(&totalCapacity)

	resp.Diagnostics.Append(resp.State.Set(ctx, &data)...)
}

func (r *TablesResource) Update(ctx context.Context, req resource.UpdateRequest, resp *resource.UpdateResponse) {
	var data TablesResourceModel

	resp.Diagnostics.Append(req.Plan.Get(ctx, &data)...)
	if resp.Diagnostics.HasError() {
		return
	}


	// Recalculate cost and capacity
	var costPerTable *big.Float
	var seatsPerTable *big.Float
	size := data.Size.ValueString()
	switch size {
	case "small":
		costPerTable = big.NewFloat(50.00)
		seatsPerTable = big.NewFloat(2.0)
	case "medium":
		costPerTable = big.NewFloat(100.00)
		seatsPerTable = big.NewFloat(4.0)
	case "large":
		costPerTable = big.NewFloat(150.00)
		seatsPerTable = big.NewFloat(6.0)
	default:
		costPerTable = big.NewFloat(50.00)
		seatsPerTable = big.NewFloat(2.0)
	}

	quantity := data.Quantity.ValueBigFloat()
	var totalCost big.Float
	totalCost.Mul(quantity, costPerTable)
	finalCost := ApplyUpcharge(&totalCost, r.client.Upcharge)
	data.Cost = types.NumberValue(finalCost)

	var totalCapacity big.Float
	totalCapacity.Mul(quantity, seatsPerTable)
	data.Capacity = types.NumberValue(&totalCapacity)

	var state TablesResourceModel
	resp.Diagnostics.Append(req.State.Get(ctx, &state)...)
	if resp.Diagnostics.HasError() {
		return
	}

	if !data.Size.Equal(state.Size) {
		id := fmt.Sprintf("tables-%s-%d", size, len(size))
		data.Id = types.StringValue(id)
	} else {
		data.Id = state.Id
	}

	resp.Diagnostics.Append(resp.State.Set(ctx, &data)...)
}

func (r *TablesResource) Delete(ctx context.Context, req resource.DeleteRequest, resp *resource.DeleteResponse) {
	var data TablesResourceModel

	resp.Diagnostics.Append(req.State.Get(ctx, &data)...)
	if resp.Diagnostics.HasError() {
		return
	}


	tflog.Trace(ctx, "deleted a tables resource", map[string]any{
		"id": data.Id.ValueString(),
	})
}

func (r *TablesResource) ImportState(ctx context.Context, req resource.ImportStateRequest, resp *resource.ImportStateResponse) {
	resource.ImportStatePassthroughID(ctx, path.Root("id"), req, resp)
}
