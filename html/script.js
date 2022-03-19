var cartItems = {};
var PointofSale = {};
var Register = {};
var SelfCheckout = {};
var ManagementDashboard = {};
var receivedData = {};
var organizedData = {
    items: {},
    transactions: {},
    customers: {},
    employees: {},
};
var selectedOrder = "0";
var chart_data = {};
var myChart;
var transactionData = {};
var currentDisplay = '';

function prepareTabletDisplay(data) {
    var mainDiv = d3.select(`#products`);
    var rowDiv = mainDiv.append('div').classed('row', true)
    data.items.forEach((item, index) => {
        var coldiv = rowDiv.append('div').classed('col-md-3 product', true).attr('id', item.hash).attr('price', item.price).attr('maxquant', item.quantity);
        coldiv.append('div').classed('center', true).classed('row', true).append('div').classed('col-md-12', true).append('img').classed('center', true).attr('src', `nui://qb-inventory/html/images/${item.image}`);
        coldiv.append('div').classed('center', true).classed('row', true).append('div').classed('col-md-12', true).text(item.name);
        if (index % 4 == 3) {
            rowDiv = mainDiv.append('div').classed('row', true);
        }
    });
}

function prepareOrders() {
    $('#ordersection').html('');
    var mainDiv = d3.select('#ordersection');
    var rowDiv = mainDiv.append('div').classed('row', true)
    for (var key in receivedData) {
        var obj = receivedData[key];
        var coldiv = rowDiv.append('div').classed('col-md-4 order', true).attr('id', key);
        coldiv.append('img').classed('ticket', true).attr('src', `nui://qb-inventory/html/images/${obj.entrantData.businessname}-ticket.png`);
        var itemsdiv = rowDiv.append('div').classed('col-md-8 items', true);
        var itemRow = itemsdiv.append('div').classed('row', true);
        for (var itemId in obj.items) {
            var item = obj.items[itemId];
            var itemCon = itemRow.append('div').classed('col-md-4', true)
            itemCon.append('div').classed('center', true).classed('row', true).append('div').classed('col-md-12', true).append('img').attr('src', `${item.image}`);
            itemCon.append('div').classed('center', true).classed('row', true).append('div').classed('col-md-12', true).text(`${item.label} x${item.ordered}`);
        }
        rowDiv.append('hr');
        rowDiv = mainDiv.append('div').classed('row', true);
    }
}

function organizeData(data) {
    organizedData = {
        items: {},
        transactions: {},
        customers: {},
        employees: {},
    };
    for (i=0;i<data.transactions.length;i++) {
        data.transactions[i].items = JSON.parse(data.transactions[i].items);
        var dateStr = moment(data.transactions[i].date).format('L'); 
        for (var key in data.transactions[i].items) {
            if (!data.transactions[i].items.hasOwnProperty(key)) continue;
            if (data.transactions[i].payercitizenid in organizedData.customers) {
                organizedData.customers[data.transactions[i].payercitizenid].itemssold += data.transactions[i].items[key].ordered;
            } else {
                organizedData.customers[data.transactions[i].payercitizenid] = {
                    revenue: 0,
                    sales: 0,
                    itemssold: data.transactions[i].items[key].ordered,
                    name: `${data.transactions[i].payerfirstname} ${data.transactions[i].payerlastname}`
                }
            }
            if (key in organizedData.items) {
                organizedData.items[key].quantity += data.transactions[i].items[key].ordered;
                organizedData.items[key].revenue += data.transactions[i].items[key].ordered * data.transactions[i].items[key].price;
                if (data.transactions[i].payercitizenid in organizedData.items[key].customers) {
                    organizedData.items[key].customers[data.transactions[i].payercitizenid].quantity += data.transactions[i].items[key].ordered;
                    organizedData.items[key].customers[data.transactions[i].payercitizenid].revenue += data.transactions[i].items[key].ordered * data.transactions[i].items[key].price;
                } else {
                    organizedData.items[key].customers[data.transactions[i].payercitizenid] = {
                        quantity: data.transactions[i].items[key].ordered,
                        revenue: data.transactions[i].items[key].ordered * data.transactions[i].items[key].price,
                        name: `${data.transactions[i].payerfirstname} ${data.transactions[i].payerlastname}`
                    }
                }
                if (!data.transactions[i].selfcheckout) {
                    if (data.transactions[i].entrantcitizenid in organizedData.items[key].employees) {
                        organizedData.items[key].employees[data.transactions[i].entrantcitizenid].quantity += data.transactions[i].items[key].ordered;
                        organizedData.items[key].employees[data.transactions[i].entrantcitizenid].revenue += data.transactions[i].items[key].ordered * data.transactions[i].items[key].price;
                    } else {
                        organizedData.items[key].employees[data.transactions[i].entrantcitizenid] = {
                            quantity: data.transactions[i].items[key].ordered,
                            revenue: data.transactions[i].items[key].ordered * data.transactions[i].items[key].price,
                            name: `${data.transactions[i].entrantfirstname} ${data.transactions[i].entrantlastname}`
                        }
                    }
                }
            } else {
                organizedData.items[key] = {
                    label: data.transactions[i].items[key].label,
                    quantity: data.transactions[i].items[key].ordered,
                    revenue: data.transactions[i].items[key].ordered * data.transactions[i].items[key].price,
                    image: data.transactions[i].items[key].image,
                    customers: {},
                    employees: {}
                }
                organizedData.items[key].customers[data.transactions[i].payercitizenid] = {
                    quantity: data.transactions[i].items[key].ordered,
                    revenue: data.transactions[i].items[key].ordered * data.transactions[i].items[key].price,
                    name: `${data.transactions[i].payerfirstname} ${data.transactions[i].payerlastname}`
                }
                if (data.transactions[i].payercitizenid in organizedData.customers) {
                    organizedData.customers[data.transactions[i].payercitizenid].itemssold += data.transactions[i].items[key].ordered;
                } else {
                    organizedData.customers[data.transactions[i].payercitizenid] = {
                        revenue: 0,
                        sales: 0,
                        itemssold:0,
                        name: `${data.transactions[i].payerfirstname} ${data.transactions[i].payerlastname}`
                    }
                }
            }
            if (!data.transactions[i].selfcheckout) {
                if (data.transactions[i].entrantcitizenid in organizedData.employees) {
                    organizedData.employees[data.transactions[i].entrantcitizenid].itemssold += data.transactions[i].items[key].ordered
                } else {
                    organizedData.employees[data.transactions[i].entrantcitizenid] = {
                        itemssold: data.transactions[i].items[key].ordered,
                        revenue: 0,
                        sales: 0,
                        name: `${data.transactions[i].entrantfirstname} ${data.transactions[i].entrantlastname}`
                    }
                }
            }
            if (dateStr in organizedData.transactions) {
                organizedData.transactions[dateStr].itemssold += data.transactions[i].items[key].ordered
            } else {
                organizedData.transactions[dateStr] = {
                    itemssold: data.transactions[i].items[key].ordered,
                    sales: 0,
                    revenue: 0
                }
            }
        }
        if (data.transactions[i].payercitizenid in organizedData.customers) {
            organizedData.customers[data.transactions[i].payercitizenid].revenue += data.transactions[i].price;
            organizedData.customers[data.transactions[i].payercitizenid].sales += 1;
        } else {
            organizedData.customers[data.transactions[i].payercitizenid] = {
                revenue: data.transactions[i].price,
                sales: 1,
                itemssold:0,
                name: `${data.transactions[i].payerfirstname} ${data.transactions[i].payerlastname}`
            }
        }
        if (dateStr in organizedData.transactions) {
            organizedData.transactions[dateStr].revenue += data.transactions[i].price;
            organizedData.transactions[dateStr].sales += 1;
        } else {
            organizedData.transactions[dateStr] = {
                revenue: data.transactions[i].price,
                sales: 1,
                itemssold: 0
            }
        }
        if (!data.transactions[i].selfcheckout) {
            if (data.transactions[i].entrantcitizenid in organizedData.employees) {
                organizedData.employees[data.transactions[i].entrantcitizenid].revenue += data.transactions[i].price
                organizedData.employees[data.transactions[i].entrantcitizenid].sales += 1
            } else {
                organizedData.employees[data.transactions[i].entrantcitizenid] = {
                    revenue: data.transactions[i].price,
                    sales: 1,
                    itemssold: 0,
                    name: `${data.transactions[i].entrantfirstname} ${data.transactions[i].entrantlastname}`
                }
            }
        }
    }
}

function updateCart() {
    $('#cart').html('');
    var cart = d3.select('#cart')
    var total = 0;
    for (var key in cartItems) {
        if (!cartItems.hasOwnProperty(key)) continue;
        var row = cart.append('div').classed('row', true).attr('id', `cart-${key}`);
        var col = row.append('div').classed('col-md-12', true);
        col.append('img').attr('src', `nui://qb-inventory/html/images/${key}.png`);
        col.append('span').classed('quantity', true).text(`x${cartItems[key].ordered}`);
        col.append('btn').classed('btn', true).classed('btn-danger', true).attr('id', `item-${key}`).text('Remove');
        row.append('div').classed('col-md-12', true).text(`${cartItems[key].label}`)
        total += parseInt(cartItems[key].price) * cartItems[key].ordered;
    }
    $('#total').text(total);
}

function NotInStock() {
    $('#unavailable').css({"display":"block"});
    $('#unavailable').animate({
        opacity: 1.0,
    }, 1000, function(){
        $('#unavailable').css({"display":"none"});
    });
}

function structureItems() {
    var itemData = {};
    var x = {
       
    };
    var y = {
        type: 'linear',
        display: true,
        position: 'left',
        beginAtZero: true,
    };
    var itemData = {
        labels: [],
        keys: [],
        itemssold: {
            values: [],
            label: "Units Sold"
        },
        customers: {
            items: {},
        },
        employees: {
            items: {}
        },
        revenue: {
            values: [],
            label: "Revenue"
        },
        x: x,
        y: y,
        type: 'bar',
    };
    for (var key in organizedData.items) {
        if (!organizedData.items.hasOwnProperty(key)) continue;
        itemData.keys.push(key)
        itemData.labels.push(organizedData.items[key].label);
        itemData.itemssold.values.push(organizedData.items[key].quantity);
        itemData.revenue.values.push(organizedData.items[key].revenue);
        for (var custkey in organizedData.items[key].customers) {
            if (!organizedData.items[key].customers.hasOwnProperty(custkey)) continue;
            if (!itemData.customers.items.hasOwnProperty(organizedData.items[key].label)) {
                itemData.customers.items[organizedData.items[key].label] = {
                    labels: [],
                    itemssold: {
                        values: [],
                        label: organizedData.items[key].label + ' Units Purchased'
                    },
                    revenue: {
                        values: [],
                        label: organizedData.items[key].label + ' Revenue'
                    }
                };
            }
            itemData.customers.items[organizedData.items[key].label].itemssold.values.push(organizedData.items[key].customers[custkey].quantity);
            itemData.customers.items[organizedData.items[key].label].revenue.values.push(organizedData.items[key].customers[custkey].revenue);
            itemData.customers.items[organizedData.items[key].label].labels.push(organizedData.items[key].customers[custkey].name);
        }
        for (var empkey in organizedData.items[key].employees) {
            if (!organizedData.items[key].employees.hasOwnProperty(empkey)) continue;
            if (!itemData.employees.items.hasOwnProperty(organizedData.items[key].label)) {
                itemData.employees.items[organizedData.items[key].label] = {
                    labels: [],
                    itemssold: {
                        values: [],
                        label: organizedData.items[key].label + ' Units Sold'
                    },
                    revenue: {
                        values: [],
                        label: organizedData.items[key].label + ' Revenue'
                    }
                };
            }
            itemData.employees.items[organizedData.items[key].label].itemssold.values.push(organizedData.items[key].employees[empkey].quantity);
            itemData.employees.items[organizedData.items[key].label].revenue.values.push(organizedData.items[key].employees[empkey].revenue);
            itemData.employees.items[organizedData.items[key].label].labels.push(organizedData.items[key].employees[empkey].name);
        }
    }
    return itemData;
}

function structureEmployees() {
    var employeeData = {};
    var x = {

    };
    var y = {
        type: 'linear',
        display: true,
        position: 'left',
        beginAtZero: true,
    };
    var employeeData = {
        keys: [],
        labels: [],
        itemssold: {
            values: [],
            label: "Units Sold"
        },
        sales: {
            values: [],
            label: "Sales"
        },
        revenue: {
            values: [],
            label: "Revenue"
        },
        x: x,
        y: y,
        type: 'bar',
    };
    for (var key in organizedData.employees) {
        if (!organizedData.employees.hasOwnProperty(key)) continue;
        employeeData.keys.push(key)
        employeeData.labels.push(organizedData.employees[key].name);
        employeeData.itemssold.values.push(organizedData.employees[key].itemssold);
        employeeData.sales.values.push(organizedData.employees[key].sales);
        employeeData.revenue.values.push(organizedData.employees[key].revenue);
    }
    return employeeData;
}

function structureCustomers() {
    var customerData = {};
    var x = {

    };
    var y = {
        type: 'linear',
        display: true,
        position: 'left',
        beginAtZero: true,
    };
    var customerData = {
        keys: [],
        labels: [],
        itemssold: {
            values: [],
            label: "Units Purchased"
        },
        sales: {
            values: [],
            label: "Purchases"
        },
        revenue: {
            values: [],
            label: "Revenue"
        },
        x: x,
        y: y,
        type: 'bar',
    };
    for (var key in organizedData.customers) {
        if (!organizedData.customers.hasOwnProperty(key)) continue;
        customerData.keys.push(key)
        customerData.labels.push(organizedData.customers[key].name);
        customerData.itemssold.values.push(organizedData.customers[key].itemssold);
        customerData.sales.values.push(organizedData.customers[key].sales);
        customerData.revenue.values.push(organizedData.customers[key].revenue);
    }
    return customerData;
}

function structureTransactions() {
    var x = {
        type: 'time',
        time: {
            displayFormats: {'day': 'DD/MM'},
            tooltipFormat: 'DD/MM/YYYY',
            unit: 'day'
        }
    };
    var y = {
        type: 'linear',
        display: true,
        position: 'left',
        beginAtZero: true,
    };
    var transactionData = {
        labels: [],
        keys: [],
        itemssold: {
            values: [],
            label: "Items Sold"
        },
        sales: {
            values: [],
            label: "Sales"
        },
        revenue: {
            values: [],
            label: "Revenue"
        },
        x: x,
        y: y,
        type: 'line',
    };
    for (var key in organizedData.transactions) {
        if (!organizedData.transactions.hasOwnProperty(key)) continue;
        transactionData.keys.push(key);
        transactionData.labels.push(key);
        transactionData.itemssold.values.push(organizedData.transactions[key].itemssold);
        transactionData.sales.values.push(organizedData.transactions[key].sales);
        transactionData.revenue.values.push(organizedData.transactions[key].revenue);
    }
    return transactionData;
}

function sortChartDesc(labels, chartData) {
    arrayOfObj = labels.map(function(d, i) {
        return {
          label: d,
          data: chartData[i] || 0
        };
    });
      
    sortedArrayOfObj = arrayOfObj.sort(function(a, b) {
        return b.data - a.data;
    });
    newArrayLabel = [];
    newArrayData = [];
    sortedArrayOfObj.forEach(function(d){
        newArrayLabel.push(d.label);
        newArrayData.push(d.data);
    });
    return [newArrayLabel, newArrayData];
}

function createChartConfig(key, subkey) {
    var chartlabels = [];
    var values = [];
    if (chart_data[key].type == 'bar') {
        var result = sortChartDesc(chart_data[key].labels, chart_data[key][subkey].values);
        chartlabels = result[0];
        values = result[1];
    } else {
        chartlabels = chart_data[key].labels
        values = chart_data[key][subkey].values
    }
    var data = {
        labels: chartlabels,
        datasets: [{
            label: chart_data[key][subkey].label,
            backgroundColor: 'rgb(255, 99, 132)',
            borderColor: 'rgb(255, 99, 132)',
            data: values,
            yAxisID: 'y'
        }]
    };
    var config = {
        type: chart_data[key].type,
        data: data,
        options: {
            responsive: true,
            interaction: {
                mode: 'index',
                intersect: false
            },
            stacked: false,
            plugins: {
                title: {
                    display: true,
                    text: chart_data[key][subkey].label
                }
            },
            onClick:function(evt){
                const points = myChart.getElementsAtEventForMode(evt, 'nearest', { intersect: true }, true);
                if (points.length) {
                    const firstPoint = points[0];
                    if (chart_data[key].type === 'bar') {
                        const label = chartlabels[firstPoint.index];
                        if (key === 'items') {
                            updateChartClick(key, 'customers', label, subkey);
                        } else if (key === 'customers') {
                            updateChartClick(key, 'items', label, subkey);
                        } else if (key === 'employees') {
                            updateChartClick(key, 'items', label, subkey);
                        }
                    }
                }
            },
            scales: {
                x: chart_data[key].x,
                y: chart_data[key].y
            }
        }
    };
    return config;
}

function createChartConfigClick(mainkey, filterkey, breakdown, viewkey) {
    var labels;
    var values;
    if (chart_data[mainkey].type == 'bar') {
        var result = sortChartDesc(chart_data[mainkey][filterkey][mainkey][breakdown].labels, chart_data[mainkey][filterkey][mainkey][breakdown][viewkey].values);
        labels = result[0];
        values = result[1];
    }
    var data = {
        labels: labels,
        datasets: [{
            label: chart_data[mainkey][filterkey][mainkey][breakdown][viewkey].label,
            backgroundColor: 'rgb(255, 99, 132)',
            borderColor: 'rgb(255, 99, 132)',
            data: values,
            yAxisID: 'y'
        }]
    };

    var config = {
        type: chart_data[mainkey].type,
        data: data,
        options: {
            responsive: true,
            interaction: {
                mode: 'index',
                intersect: false
            },
            stacked: false,
            plugins: {
                title: {
                    display: true,
                    text: chart_data[mainkey][filterkey][mainkey][breakdown][viewkey].label
                }
            },
            scales: {
                x: chart_data[mainkey].x,
                y: chart_data[mainkey].y
            }
        }
    };
    return config;
}

function updateChart(key, subkey) {
    var config = createChartConfig(key, subkey);
    if (config.data.labels.length > 20) {
        config.data.labels.length = 20;
        config.data.datasets[0].data.length = 20;
    }
    $('#businesschart').html('<div id="chartButtons" class="row"></div><div class="row"><canvas id="myChart"></canvas></div>');
    var chartButtons = d3.select('#chartButtons')
    chartButtons.html('');
    if (key === 'transactions') {
        chartButtons.append('div').classed('col-md-4', true).append('button').classed('btn btn-primary chart-button', true).attr('key', 'transactions').attr('subkey', 'revenue').text('Revenue');
        chartButtons.append('div').classed('col-md-4', true).append('button').classed('btn btn-primary chart-button', true).attr('key', 'transactions').attr('subkey', 'itemssold').text('Items Sold');
        chartButtons.append('div').classed('col-md-4', true).append('button').classed('btn btn-primary chart-button', true).attr('key', 'transactions').attr('subkey', 'sales').text('Sales');
    } else if (key === 'items') {
        chartButtons.append('div').classed('col-md-6', true).append('button').classed('btn btn-primary chart-button', true).attr('key', 'items').attr('subkey', 'revenue').text('Revenue');
        chartButtons.append('div').classed('col-md-6', true).append('button').classed('btn btn-primary chart-button', true).attr('key', 'items').attr('subkey', 'itemssold').text('Items Sold');
    } else if (key === 'customers') {
        chartButtons.append('div').classed('col-md-4', true).append('button').classed('btn btn-primary chart-button', true).attr('key', 'customers').attr('subkey', 'revenue').text('Revenue');
        chartButtons.append('div').classed('col-md-4', true).append('button').classed('btn btn-primary chart-button', true).attr('key', 'customers').attr('subkey', 'itemssold').text('Items Sold');
        chartButtons.append('div').classed('col-md-4', true).append('button').classed('btn btn-primary chart-button', true).attr('key', 'customers').attr('subkey', 'sales').text('Sales');
    } else if (key === 'employees') {
        chartButtons.append('div').classed('col-md-4', true).append('button').classed('btn btn-primary chart-button', true).attr('key', 'employees').attr('subkey', 'revenue').text('Revenue');
        chartButtons.append('div').classed('col-md-4', true).append('button').classed('btn btn-primary chart-button', true).attr('key', 'employees').attr('subkey', 'itemssold').text('Items Sold');
        chartButtons.append('div').classed('col-md-4', true).append('button').classed('btn btn-primary chart-button', true).attr('key', 'employees').attr('subkey', 'sales').text('Sales');
    }
    myChart = new Chart($('#myChart'), config);
}

function updateChartClick(mainkey, filterkey, breakdown, viewkey) {
    var config = createChartConfigClick(mainkey, filterkey, breakdown, viewkey);
    if (config.data.labels.length > 20) {
        config.data.labels.length = 20;
        config.data.datasets[0].data.length = 20;
    }
    $('#businesschart').html('<div id="chartButtons" class="row"></div><div class="row"><canvas id="myChart"></canvas></div>');
    var chartButtons = d3.select('#chartButtons');
    chartButtons.html('');
    var divwidth = 6;
    if (mainkey === 'items') {
        if (filterkey == 'customers') {
            if (chart_data[mainkey]['employees'][mainkey].hasOwnProperty(breakdown)) {
                divwidth = 4;
                chartButtons.append('div').classed(`col-md-${divwidth}`, true).append('button').classed('btn btn-primary sub-chart-button', true).attr('mainkey', mainkey).attr('filterkey', 'employees').attr('breakdown', breakdown).attr('viewkey', viewkey).text('Employees');
            }            
        } else {
            if (chart_data[mainkey]['customers'][mainkey].hasOwnProperty(breakdown)) {
                divwidth = 4;
                chartButtons.append('div').classed(`col-md-${divwidth}`, true).append('button').classed('btn btn-primary sub-chart-button', true).attr('mainkey', mainkey).attr('filterkey', 'customers').attr('breakdown', breakdown).attr('viewkey', viewkey).text('Customers');
            }
        }
        chartButtons.append('div').classed(`col-md-${divwidth}`, true).append('button').classed('btn btn-primary sub-chart-button', true).attr('mainkey', mainkey).attr('filterkey', filterkey).attr('breakdown', breakdown).attr('viewkey', 'revenue').text('Revenue');
        chartButtons.append('div').classed(`col-md-${divwidth}`, true).append('button').classed('btn btn-primary sub-chart-button', true).attr('mainkey', mainkey).attr('filterkey', filterkey).attr('breakdown', breakdown).attr('viewkey', 'itemssold').text('Items Sold');        
    }
    myChart = new Chart($('#myChart'), config);
}

function updateTransactions() {
    var transactionTable = d3.select('#transactionData');
    transactionTable.html('');
    var transactionTHeadRow = transactionTable.append('thead').append('tr');
    transactionTHeadRow.append('th').text('Date');
    transactionTHeadRow.append('th').text('Customer');
    transactionTHeadRow.append('th').text('Employee/Selfcheckout');
    transactionTHeadRow.append('th').text('Items Ordered');
    transactionTHeadRow.append('th').text('Order Total');
    var transactionTbody = transactionTable.append('tbody');
    for (var key in transactionData.transactions) {
        if (!transactionData.transactions.hasOwnProperty(key)) continue;
        var itemsPurchased = 0;
        for (var item in transactionData.transactions[key].items) {
            itemsPurchased += transactionData.transactions[key].items[item].ordered;
        }
        var transactionTRow = transactionTbody.append('tr').attr('id', `transaction-${key}`);
        transactionTRow.append('td').text(`${moment(transactionData.transactions[key].date).format('MMMM Do YYYY, h:mm:ss a', refresh=true)}`);
        transactionTRow.append('td').text(`${transactionData.transactions[key].payerfirstname} ${transactionData.transactions[key].payerlastname}`);
        transactionTRow.append('td').text(`${transactionData.transactions[key].selfcheckout ? 'Selfserve' : transactionData.transactions[key].entrantfirstname + ' ' + transactionData.transactions[key].entrantlastname}`);
        transactionTRow.append('td').text(`${itemsPurchased}`);
        transactionTRow.append('td').text(`${transactionData.transactions[key].price}`);
    }
    
}

function updateChartData() {
    chart_data.items = structureItems();
    chart_data.employees = structureEmployees();
    chart_data.customers = structureCustomers();
    chart_data.transactions = structureTransactions();
}

PointofSale.Open = function(data) {
    currentDisplay = 'pos';
    receivedData = data;
    $('#products').html('');
    $('#cart').html('');
    $('#buttoncontainer').html('');
    $('#total').text('0');
    $('#orders').hide();
    $('#pos').show();
    $('#productSection').show();
    prepareTabletDisplay(receivedData);
    d3.select('#buttoncontainer').append('button').classed('btn btn-success send-register', true).text('Send to Register')
    cartItems = {};
}

Register.Open = function(data) {
    currentDisplay = 'register';
    receivedData = data
    $('#products').html('');
    $('#cart').html('');
    $('#buttoncontainer').html('');
    $('#total').text('0');
    $('#productSection').hide();
    $('#pos').show();
    $('#orders').show();
    prepareOrders();
    d3.select('#buttoncontainer').append('button').classed('btn btn-success purchase', true).text('Purchase')
    cartItems = {};
}

SelfCheckout.Open = function(data) {
    currentDisplay = 'selfcheckout';
    receivedData = data;
    $('#products').html('');
    $('#cart').html('');
    $('#buttoncontainer').html('');
    $('#total').text('0');
    $('#orders').hide();
    $('#pos').show();
    $('#productSection').show();
    prepareTabletDisplay(receivedData);
    d3.select('#buttoncontainer').append('button').classed('btn btn-success self-checkout', true).text('Purchase')
    cartItems = {};
}

ManagementDashboard.Open = function(data) {
    $('#dashboardtitle').html(`${data.jobtitle} Management Dashboard`)
    $('.catActive').removeClass('catActive');
    $('#businessdata').html('<table id="transactionData" class="table table-dark table-hover"></table>');
    $('#businessdata').hide();
    $('#expensedata').hide();
    $('#selectedTransaction').hide();
    $('#managementDashboard').show();
    $('#mainMenuOptions').show();
    transactionData = data;
    organizeData(data);
    updateChartData();
    updateChart('transactions', 'revenue');
    updateTransactions();
}

PointofSale.Close = function() {
    $('#pos').hide();
    $('#productsection').hide();
    cartItems = {};
};

Register.Close = function() {
    $('#pos').hide();
    $('#orders').hide();
    cartItems = {};
};

SelfCheckout.Close = function() {
    $('#pos').hide();
    $('#productsection').hide();
    cartItems = {};
};

ManagementDashboard.Close = function() {
    $('#managementDashboard').hide();
    $('#mainMenuOptions').hide();
    $('#chartMenuOptions').hide();
}

ManagementDashboard.Update = function(field) {
    $('#myChart').hide();
    $('#businessdata').hide();
    $('#expensedata').hide();
    $('#selectedTransaction').hide();
    $(`#${field}`).show();
}

$(document).on('click', '.chart-button', function(event) {
    event.preventDefault();
    var elem = d3.select(this);
    updateChart(elem.attr('key'), elem.attr('subkey'));
});

$(document).on('click', '.sub-chart-button', function(event) {
    event.preventDefault();
    var elem = d3.select(this);
    updateChartClick(elem.attr('mainkey'), elem.attr('filterkey'), elem.attr('breakdown'), elem.attr('viewkey'));
});

$(document).on('click', '#transactionMenuOption', function() {
    ManagementDashboard.Update('businessdata');
    $.fn.dataTable.moment('MMMM Do YYYY, h:mm:ss a');
    $('#transactionData').DataTable({
        paginate: true,
        "pagingType": "full_numbers",
        order: [[0, 'desc']]
    });
    d3.select('input').classed('form-control', true);
    d3.select('select').classed('form-control', true);
});

$(document).on('click', '#chartMenuOption', function() {
    ManagementDashboard.Update('myChart');
    $('#mainMenuOptions').hide();
    $('#chartMenuOptions').show();
    $('#timeChartMenuOption').addClass('catActive');
    updateChart('transactions', 'revenue');
});

$(document).on('click', '#backMain', function() {
    $('#chartMenuOptions').hide();
    $('#mainMenuOptions').show();
    $('#transactionMenuOption').click();
    $('#transactionMenuOption').addClass('catActive');
});

$(document).on('click', '#expenseMenuOption', function() {
    ManagementDashboard.Update('expensedata');
});

$(document).on('click', '#timeChartMenuOption', function(event) {
    ManagementDashboard.Update('myChart');
    updateChart('transactions', 'revenue');
});

$(document).on('click', '#revenueChartMenuOption', function() {
    ManagementDashboard.Update('myChart');
    updateChart('items', 'revenue');
});

$(document).on('click', '#businessChartMenuOption', function() {
    ManagementDashboard.Update('myChart');
    updateChart('customers', 'revenue');
});

$(document).on('click', '#employeeChartMenuOption', function() {
    ManagementDashboard.Update('myChart');
    updateChart('employees', 'revenue');
});

$(document).on('click', '.menuoption', function() {
    $('.catActive').removeClass('catActive');
    $(this).addClass('catActive');
});

$(document).on('click', '.product', function(){
    if (cartItems.hasOwnProperty(this.id)) {
        if (currentDisplay !== 'pos') {
            var maxquant = parseInt(d3.select(this).attr('maxquant'));
            if (maxquant >= cartItems[this.id].ordered + 1) {
                cartItems[this.id].ordered += 1
            } else {
                NotInStock();
            }
        } else {
            cartItems[this.id].ordered += 1
        }
    } else {
        cartItems[this.id] = {
            ordered: 1,
            label: $(this).text(),
            price: parseInt(d3.select(this).attr('price')),
            image: $(this).find('img').attr('src')
        }
    }
    updateCart();
});

$(document).on('click', 'tr', function(){
    var selectedTransaction = transactionData.transactions[this.id.split('-')[1]];
    $('#selectedTransaction').html('');
    $('#selectedTransaction').show();
    var selectElem = d3.select('#selectedTransaction');
    selectElem.append('div').classed('row center', true).append('div').classed('col-md-12', true).append('h2').text(`Transaction #${this.id.split('-')[1]}`);
    var rowDiv = selectElem.append('div').classed('row', true);
    var leftColDiv = rowDiv.append('div').classed('col-md-4', true).append('div').classed('row', true);
    leftColDiv.append('div').classed('col-md-6 h3', true).text(`Name:`);
    leftColDiv.append('div').classed('col-md-6 h3', true).text(`${selectedTransaction.payerfirstname} ${selectedTransaction.payerlastname}`);
    var rightColDiv = rowDiv.append('div').classed('col-md-8', true).append('div').classed('row', true);
    rightColDiv.append('div').classed('col-md-4', true);
    rightColDiv.append('div').classed('col-md-4 center', true).text('Item');
    rightColDiv.append('div').classed('col-md-4 center', true).text('Quantity');
    for (var key in selectedTransaction.items) {
        if (!selectedTransaction.items.hasOwnProperty(key)) continue;
        var item = selectedTransaction.items[key];
        rightColDiv.append('div').classed('col-md-4', true).classed('right', true).append('img').attr('src', item.image).text(item.label);
        rightColDiv.append('div').classed('col-md-4 center vertical', true).text(item.label);
        rightColDiv.append('div').classed('col-md-4 center vertical', true).text(item.ordered);
    }
    leftColDiv.append('div').classed('col-md-6 h3', true).text(`Total:`);
    leftColDiv.append('div').classed('col-md-6 h3', true).text(`$${selectedTransaction.price}`);
    if (selectedTransaction.selfcheckout) {
        leftColDiv.append('div').classed('col-md-6 h3', true).text(`Type:`);
        leftColDiv.append('div').classed('col-md-6 h3', true).text(`Self Checkout`);
    } else {
        leftColDiv.append('div').classed('col-md-6 h3', true).text(`Served By:`);
        leftColDiv.append('div').classed('col-md-6 h3', true).text(`${selectedTransaction.entrantfirstname} ${selectedTransaction.entrantlastname}`);
    }
    
});

$(document).on('click', '.order', function(){
    cartItems = receivedData[this.id].items
    var total = 0;
    for (var key in cartItems) {
        if (!cartItems.hasOwnProperty(key)) continue;
        total += parseInt(cartItems[key].price) * cartItems[key].ordered;
    }
    selectedOrder = this.id
    $('#total').text(total);
});

$(document).on('click', '.btn-danger', function(event){
    event.preventDefault();
    var id = this.id.split('-')[1];
    if (cartItems.hasOwnProperty(id)) {
        delete cartItems[id];
    }
    $(id).remove();
    updateCart();
});

$(document).on('click', '.send-register', function(){
    if (Object.keys(cartItems).length > 0) {
        $.post('https://qb-pos/SendRegister', JSON.stringify({
            data: cartItems,
            total: $('#total').text(),
            entrantData: receivedData
        }), function(complete) {
            if (complete) {
                PointofSale.Close();
                Register.Close();
                SelfCheckout.Close();
                $.post('https://qb-pos/closePOS')
            }
        });
    } else {
        $.post('https://qb-pos/EmptyCart');
    }
});

$(document).on('click', '.purchase', function(){
    if (Object.keys(cartItems).length > 0) {
        $.post('https://qb-pos/AcceptTransaction', JSON.stringify({
            data: cartItems,
            total: $('#total').text(),
            entrantData: receivedData,
            key: selectedOrder
        }), function(complete) {
            if (complete) {
                PointofSale.Close();
                Register.Close();
                SelfCheckout.Close();
                $.post('https://qb-pos/closePOS')
            }
        });
    } else {
        $.post('https://qb-pos/EmptyCart');
    }
});

$(document).on('click', '.self-checkout', function(){
    if (Object.keys(cartItems).length > 0) {
        $.post('https://qb-pos/SelfCheckout', JSON.stringify({
            data: cartItems,
            total: $('#total').text(),
            entrantData: receivedData
        }), function(complete) {
            if (complete) {
                PointofSale.Close();
                Register.Close();
                SelfCheckout.Close();
                ManagementDashboard.Close();
                $.post('https://qb-pos/closePOS');
            }
        });
    } else {
        $.post('https://qb-pos/EmptyCart');
    }
});

document.onreadystatechange = () => {
    if (document.readyState === "complete") {
        window.addEventListener('message', function(event) {
            if (event.data.type == "pos") {
                PointofSale.Open(event.data.data);
            } else if (event.data.type == 'selfcheckout') {
                SelfCheckout.Open(event.data.data);
            } else if (event.data.type == 'openPayment') {
                Register.Open(event.data.data);
            } else if (event.data.type == 'manDash') {
                ManagementDashboard.Open(event.data.data);
            }
        });
    };
};

$(document).on('keydown', function() {
    switch(event.keyCode) {
        case 27: // ESC
            PointofSale.Close();
            Register.Close();
            SelfCheckout.Close();
            ManagementDashboard.Close();
            $.post('https://qb-pos/closePOS')
            break;
    }
});