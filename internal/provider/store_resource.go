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

var _ resource.Resource = &StoreResource{}
var _ resource.ResourceWithImportState = &StoreResource{}

func NewStoreResource() resource.Resource {
	return &StoreResource{}
}

type StoreResource struct {
	client *ProviderConfig
}

type StoreResourceModel struct {
	Name                  types.String `tfsdk:"name"`
	OvenId                types.String `tfsdk:"oven_id"`
	CookIds                types.List   `tfsdk:"cook_ids"`
	TablesId              types.String `tfsdk:"tables_id"`
	ChairsId              types.String `tfsdk:"chairs_id"`
	FridgeId              types.String `tfsdk:"fridge_id"`
	Description           types.String `tfsdk:"description"`
	Cost                  types.Number `tfsdk:"cost"`
	CustomersPerHour      types.Number `tfsdk:"customers_per_hour"`
	Id                    types.String `tfsdk:"id"`
}

func (r *StoreResource) Metadata(ctx context.Context, req resource.MetadataRequest, resp *resource.MetadataResponse) {
	resp.TypeName = req.ProviderTypeName + "_store"
}

func (r *StoreResource) Schema(ctx context.Context, req resource.SchemaRequest, resp *resource.SchemaResponse) {
	resp.Schema = schema.Schema{
		MarkdownDescription: `The complete sandwich shop resource that brings together all components into a functioning business. Demonstrates complex resource dependencies, list attributes, and computed values that aggregate costs and calculate capacity from multiple child resources.

*All pieces unite,*
*Kitchen, staff, and seating,*
*Shop comes to life.*`,

		Attributes: map[string]schema.Attribute{
			"name": schema.StringAttribute{
				MarkdownDescription: "Name of the store",
				Required:            true,
			},
			"oven_id": schema.StringAttribute{
				MarkdownDescription: "ID of the hw_oven resource (required)",
				Required:            true,
			},
			"cook_ids": schema.ListAttribute{
				ElementType:         types.StringType,
				MarkdownDescription: "List of hw_cook resource IDs (at least one required)",
				Required:            true,
			},
			"tables_id": schema.StringAttribute{
				MarkdownDescription: "ID of the hw_tables resource (required)",
				Required:            true,
			},
			"chairs_id": schema.StringAttribute{
				MarkdownDescription: "ID of the hw_chairs resource (required)",
				Required:            true,
			},
			"fridge_id": schema.StringAttribute{
				MarkdownDescription: "ID of the hw_fridge resource (required)",
				Required:            true,
			},
			"description": schema.StringAttribute{
				MarkdownDescription: "Description of the store",
				Optional:            true,
			},
			"cost": schema.NumberAttribute{
				Computed:            true,
				MarkdownDescription: "Total cost of the store (sum of all component costs)",
				PlanModifiers: []planmodifier.Number{
					numberplanmodifier.UseStateForUnknown(),
				},
			},
			"customers_per_hour": schema.NumberAttribute{
				Computed:            true,
				MarkdownDescription: "Maximum customers per hour capacity (based on cooks, tables, and oven)",
				PlanModifiers: []planmodifier.Number{
					numberplanmodifier.UseStateForUnknown(),
				},
			},
			"id": schema.StringAttribute{
				Computed:            true,
				MarkdownDescription: "Store identifier",
				PlanModifiers: []planmodifier.String{
					stringplanmodifier.UseStateForUnknown(),
				},
			},
		},
	}
}

func (r *StoreResource) Configure(ctx context.Context, req resource.ConfigureRequest, resp *resource.ConfigureResponse) {
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

func (r *StoreResource) Create(ctx context.Context, req resource.CreateRequest, resp *resource.CreateResponse) {
	var data StoreResourceModel

	resp.Diagnostics.Append(req.Plan.Get(ctx, &data)...)
	if resp.Diagnostics.HasError() {
		return
	}


	// Calculate cost and capacity based on dependencies
	// Note: In a real implementation, we would read the actual resources from state
	// For this teaching example, we compute based on reasonable assumptions
	
	// Get number of cooks
	var cookIds []types.String
	resp.Diagnostics.Append(data.CookIds.ElementsAs(ctx, &cookIds, false)...)
	if resp.Diagnostics.HasError() {
		return
	}
	numCooks := float64(len(cookIds))

	// Estimate costs based on typical values (students will optimize these)
	// These are simplified estimates - in practice, would read from actual resources
	ovenCost := big.NewFloat(1000.0)   // Average oven cost
	cookCost := big.NewFloat(160.0)    // Average daily cook cost
	tablesCost := big.NewFloat(500.0)  // Average tables cost
	chairsCost := big.NewFloat(300.0)  // Average chairs cost
	fridgeCost := big.NewFloat(500.0)  // Average fridge cost

	// Calculate total cost
	var totalCost big.Float
	totalCost.Add(&totalCost, ovenCost)
	
	var cookTotalCost big.Float
	cookTotalCost.Mul(big.NewFloat(numCooks), cookCost)
	totalCost.Add(&totalCost, &cookTotalCost)
	
	totalCost.Add(&totalCost, tablesCost)
	totalCost.Add(&totalCost, chairsCost)
	totalCost.Add(&totalCost, fridgeCost)

	// Apply upcharge if configured
	finalCost := ApplyUpcharge(&totalCost, r.client.Upcharge)
	data.Cost = types.NumberValue(finalCost)

	// Calculate customers per hour capacity
	// Based on: cooks (8-15 per hour each), tables (2 customers/hour per seat), oven (10-30/hour)
	// Simplified calculation: min of cook capacity, table capacity, oven capacity
	
	// Cook capacity: average 12 customers/hour per cook
	cookCapacity := numCooks * 12.0
	
	// Table capacity: estimate 20 seats * 2 customers/hour = 40 customers/hour
	tableCapacity := 40.0
	
	// Oven capacity: estimate 20 customers/hour
	ovenCapacity := 20.0
	
	// Customers per hour is the minimum (bottleneck)
	customersPerHour := cookCapacity
	if tableCapacity < customersPerHour {
		customersPerHour = tableCapacity
	}
	if ovenCapacity < customersPerHour {
		customersPerHour = ovenCapacity
	}

	data.CustomersPerHour = types.NumberValue(big.NewFloat(customersPerHour))

	id := fmt.Sprintf("store-%s-%d", data.Name.ValueString(), len(data.Name.ValueString()))
	data.Id = types.StringValue(id)

	tflog.Trace(ctx, "created a store resource", map[string]any{
		"id":                data.Id.ValueString(),
		"name":              data.Name.ValueString(),
		"cost":              data.Cost.ValueBigFloat().String(),
		"customers_per_hour": data.CustomersPerHour.ValueBigFloat().String(),
	})

	resp.Diagnostics.Append(resp.State.Set(ctx, &data)...)
}

func (r *StoreResource) Read(ctx context.Context, req resource.ReadRequest, resp *resource.ReadResponse) {
	var data StoreResourceModel

	resp.Diagnostics.Append(req.State.Get(ctx, &data)...)
	if resp.Diagnostics.HasError() {
		return
	}


	// Recalculate cost and capacity (same logic as Create)
	var cookIds []types.String
	resp.Diagnostics.Append(data.CookIds.ElementsAs(ctx, &cookIds, false)...)
	if resp.Diagnostics.HasError() {
		return
	}
	numCooks := float64(len(cookIds))

	ovenCost := big.NewFloat(1000.0)
	cookCost := big.NewFloat(160.0)
	tablesCost := big.NewFloat(500.0)
	chairsCost := big.NewFloat(300.0)
	fridgeCost := big.NewFloat(500.0)

	var totalCost big.Float
	totalCost.Add(&totalCost, ovenCost)
	
	var cookTotalCost big.Float
	cookTotalCost.Mul(big.NewFloat(numCooks), cookCost)
	totalCost.Add(&totalCost, &cookTotalCost)
	
	totalCost.Add(&totalCost, tablesCost)
	totalCost.Add(&totalCost, chairsCost)
	totalCost.Add(&totalCost, fridgeCost)

	finalCost := ApplyUpcharge(&totalCost, r.client.Upcharge)
	data.Cost = types.NumberValue(finalCost)

	cookCapacity := numCooks * 12.0
	tableCapacity := 40.0
	ovenCapacity := 20.0
	
	customersPerHour := cookCapacity
	if tableCapacity < customersPerHour {
		customersPerHour = tableCapacity
	}
	if ovenCapacity < customersPerHour {
		customersPerHour = ovenCapacity
	}

	data.CustomersPerHour = types.NumberValue(big.NewFloat(customersPerHour))

	resp.Diagnostics.Append(resp.State.Set(ctx, &data)...)
}

func (r *StoreResource) Update(ctx context.Context, req resource.UpdateRequest, resp *resource.UpdateResponse) {
	var data StoreResourceModel

	resp.Diagnostics.Append(req.Plan.Get(ctx, &data)...)
	if resp.Diagnostics.HasError() {
		return
	}


	// Recalculate cost and capacity (same logic as Create)
	var cookIds []types.String
	resp.Diagnostics.Append(data.CookIds.ElementsAs(ctx, &cookIds, false)...)
	if resp.Diagnostics.HasError() {
		return
	}
	numCooks := float64(len(cookIds))

	ovenCost := big.NewFloat(1000.0)
	cookCost := big.NewFloat(160.0)
	tablesCost := big.NewFloat(500.0)
	chairsCost := big.NewFloat(300.0)
	fridgeCost := big.NewFloat(500.0)

	var totalCost big.Float
	totalCost.Add(&totalCost, ovenCost)
	
	var cookTotalCost big.Float
	cookTotalCost.Mul(big.NewFloat(numCooks), cookCost)
	totalCost.Add(&totalCost, &cookTotalCost)
	
	totalCost.Add(&totalCost, tablesCost)
	totalCost.Add(&totalCost, chairsCost)
	totalCost.Add(&totalCost, fridgeCost)

	finalCost := ApplyUpcharge(&totalCost, r.client.Upcharge)
	data.Cost = types.NumberValue(finalCost)

	cookCapacity := numCooks * 12.0
	tableCapacity := 40.0
	ovenCapacity := 20.0
	
	customersPerHour := cookCapacity
	if tableCapacity < customersPerHour {
		customersPerHour = tableCapacity
	}
	if ovenCapacity < customersPerHour {
		customersPerHour = ovenCapacity
	}

	data.CustomersPerHour = types.NumberValue(big.NewFloat(customersPerHour))

	var state StoreResourceModel
	resp.Diagnostics.Append(req.State.Get(ctx, &state)...)
	if resp.Diagnostics.HasError() {
		return
	}

	if !data.Name.Equal(state.Name) {
		id := fmt.Sprintf("store-%s-%d", data.Name.ValueString(), len(data.Name.ValueString()))
		data.Id = types.StringValue(id)
	} else {
		data.Id = state.Id
	}

	resp.Diagnostics.Append(resp.State.Set(ctx, &data)...)
}

func (r *StoreResource) Delete(ctx context.Context, req resource.DeleteRequest, resp *resource.DeleteResponse) {
	var data StoreResourceModel

	resp.Diagnostics.Append(req.State.Get(ctx, &data)...)
	if resp.Diagnostics.HasError() {
		return
	}


	tflog.Trace(ctx, "deleted a store resource", map[string]any{
		"id": data.Id.ValueString(),
	})
}

func (r *StoreResource) ImportState(ctx context.Context, req resource.ImportStateRequest, resp *resource.ImportStateResponse) {
	resource.ImportStatePassthroughID(ctx, path.Root("id"), req, resp)
}
