/**
 * Created by eric.baril on 2021-02-23.
 */
function createRowNew(elem,nodeParams,nodeout){
    var newRow = $("<div>");
    var bcolor=" btn-success";

    var groupnode = $("#grouprow").clone();
    groupnode.attr('id',elem).removeAttr('hidden');
    groupnode.find(".fctin").append("<br>"+elem);
    for (var i=0;i<nodeParams[elem].length;i++){
        //console.log("sub:",nodeParams[elem][i])
            var bcolor='btn-light';
            var newcellin = $("<button>", {"class": "btn "+bcolor+" btn-sm btn-block"}).html(nodeParams[elem][i] + "<br>");
            groupnode.find(".fctin").append(newcellin);
            //displayed.push(groupsobj[inputGroups[elem]][i])

    }
    groupnode.find(".fctout").append("<br>"+elem);
    if (Object.keys(nodeout).includes(elem)){
        for (var i=0;i<nodeout[elem].length;i++){
            //console.log("sub:",nodeout[elem][i])
            var bcolor='btn-light';
            var newcellin = $("<button>", {"class": "btn "+bcolor+" btn-sm btn-block"}).html(nodeout[elem][i] + "<br>");
            groupnode.find(".fctout").append(newcellin);
            //displayed.push(groupsobj[inputGroups[elem]][i])

        }

    }
    return groupnode;
}
var displayed=[];
function createNode(name,nodeParams) {
    var newNode = $("#template").clone();
    newNode.attr('id',name).removeAttr('hidden')

    console.log("block:",name);

    //return newNode;
    var cnt=0;
    /* Create Inputs elements */
    var inputGroups=[];
    var OutputGroups=[];

    var groupsobj={};
    var groupsobjOut={};


    /*  prepping groups list */
    for (elem in nodeParams["Inputs"]) {
        for (subelem in nodeParams["Inputs"][elem]) {
            var thistag= localStorage.getItem(subelem);
            if (thistag != "") {
                if (! inputGroups.includes(thistag)) {
                    inputGroups.push(thistag);
                    groupsobj[thistag]=[];
                }
                groupsobj[thistag].push(subelem);
                displayed.push(subelem);
            }
        }
    }
    /* Create Outputs elements */
    for (elem in nodeParams["Outputs"]) {
        for (subelem in nodeParams["Outputs"][elem]) {
            var thistag= localStorage.getItem(subelem);
            if (thistag != "") {
                if (! OutputGroups.includes(thistag)) {
                    OutputGroups.push(thistag);
                    groupsobjOut[thistag]=[];
                    groupsobjOut[thistag].push(subelem);
                displayed.push(subelem);
                }

            }

        }
    }

    var midnode=$('<p/>').html('<h1><p class="text-center align-middle"><br>'+name+'<br></p></h1>');
    newNode.find(".fctcmd").append(midnode);




    for (elem in inputGroups) {
        //newNode.find(".fctin").append("<br>"+inputGroups[elem]);
        //console.log("groups",inputGroups[elem],groupsobj);
        newNode.find(".insert").append(createRowNew(inputGroups[elem],groupsobj,groupsobjOut));

    }

    /*for (elem in OutputGroups) {
        newNode.find(".fctout").append("<br>"+OutputGroups[elem]);

        for (var i=0;i<groupsobj[OutputGroups[elem]].length;i++){
            var bcolor='btn-secondary';
            var btnname = groupsobj[OutputGroups[elem]][i] + "<br>"
            var newcellin = $("<button>", {"class": "btn "+bcolor+" btn-sm btn-block"}).html(btnname);
            newNode.find(".fctout").append(newcellin);
            displayed.push(groupsobj[OutputGroups[elem]][i])
        }
    }*/





    var unassignedios= $("#grouprow").clone();
    unassignedios.attr('id',elem).removeAttr('hidden');
    unassignedios.find(".fctin").append("<br>"+elem);

    for (elem in nodeParams["Inputs"]) {
         //console.log("localstorage:",localStorage.getItem("lastname"));
        unassignedios.find(".fctin").append("<br>"+elem);

        for (subelem in nodeParams["Inputs"][elem]) {
            var bcolor='btn-secondary';

            if(!displayed.includes(subelem)){
                 var newcellin = $("<button>", {"class": "btn "+bcolor+" btn-sm btn-block"}).html(subelem + "<br>");
                unassignedios.find(".fctin").append(newcellin);
            }

        }
    }

    for (elem in nodeParams["Outputs"]) {
        unassignedios.find(".fctout").append("<br>"+elem);
        for (subelem in nodeParams["Outputs"][elem]) {
            var bcolor='btn-secondary';

            if(!displayed.includes(subelem)){
                 var newcellout = $("<button>", {"class": "btn "+bcolor+" btn-sm btn-block"}).html(subelem + "<br>");
                unassignedios.find(".fctout").append(newcellout);
            }

        }
    }



    /* Create Mid section for fcts list elements */
   // var midnode=$('<p/>').html('<h1><p class="text-center align-middle"><br>'+name+'<br></p></h1>');
    //newNode.find(".fctcmd").append(midnode);

    /*newNode.find(".fctfcts").append("Sub-Functions<br>");
    for (elem in nodeParams["fcts"]) {
        var bcolor='btn-secondary';
        var newcellfct = $("<button>", {"class": "btn "+bcolor+" btn-sm btn-block"}).html(nodeParams["fcts"][elem] + "<br>");
        newNode.find(".fctfcts").append(newcellfct);

    }*/
    //return newNode;


    /*for (elem in OutputGroups) {
        newNode.find(".fctout").append("<br>"+OutputGroups[elem]);

        for (var i=0;i<groupsobj[OutputGroups[elem]].length;i++){
            var bcolor='btn-secondary';
            var btnname = groupsobj[OutputGroups[elem]][i] + "<br>"
            var newcellin = $("<button>", {"class": "btn "+bcolor+" btn-sm btn-block"}).html(btnname);
            newNode.find(".fctout").append(newcellin);
            displayed.push(groupsobj[OutputGroups[elem]][i])
        }
    }*/

    for (elem in nodeParams["Outputs"])    {
        unassignedios.find(".fctout").append("<br>"+elem);
        for (subelem in nodeParams["Outputs"][elem]){
            var bcolor='btn-secondary';

            if(!displayed.includes(subelem)){
                var newcellout = $("<button>",{"class":"btn "+bcolor+" btn-sm btn-block"}).html(subelem+"<br>");
                unassignedios.find(".fctout").append(newcellout);
                displayed.push(subelem)
            }
        };
    }
    newNode.append(unassignedios);
    return newNode
}











function readTextFile(file, callback) {
    var rawFile = new XMLHttpRequest();
    rawFile.overrideMimeType("application/json");
    rawFile.open("GET", file, true);
    rawFile.onreadystatechange = function() {
        if (rawFile.readyState === 4 && rawFile.status == "200") {
            callback(rawFile.responseText);
        }
    }
    rawFile.send(null);
}




var datafilter=[1,2];
var outfilter=[1,2];
readTextFile("outin_list.json", function(text) {
            datafilter = JSON.parse(text);
            console.log("datafilter",datafilter);
        });
        readTextFile("inout list.json", function(text) {
            outfilter = JSON.parse(text);
            console.log("outfilter",outfilter);
        });
var filterarray=[];

function applyinputfilter(filterval){
    console.log("Apply filter:",filterval)
    switch(filterval) {
        case "rearstop":
            break;
        case "elevatorUD":
            drawnodes(data,["Elevator","Pump","Chassis"])
            break;
        case "bridgeUD":
            break;
        case "bridgetilt":
            break;
        case "bridgeguide":
            break;
        case "elevcargorear":
            drawnodes(data,["Elevator","Pump"])
            break;
        case "elevcargofron":
            drawnodes(data,["Elevator","Pump"])
            break;
        case "bridgecargo":
            drawnodes(data,["Bridge","Pump"])
            break;
    }
}
function drawnodes(data,filter){
    var values=data;
    console.log(filter,"Data:",data)
    $("#nodelist").html("");
            for (elem in values){
                //var newelem =createNode(elem,values[elem]);
                   // $("#nodelist").last().append(newelem);

                if (filter.length>0) {
                    if (filter.includes(elem)){
                        console.log("elem:",elem)
                        var newelem =createNode(elem,values[elem]);
                        $("#nodelist").last().append(newelem);
                    }

                }
                else {
                    console.log("elem:",elem)
                    var newelem =createNode(elem,values[elem]);
                    $("#nodelist").last().append(newelem);
                }

                //break

            }

}
var data="";
$( document ).ready(function() {
        //$("#top").append('<div><input type="text" id="tagname" name="lname"><br><br></div>');
        readTextFile("blocks2.json", function(text){
            data = JSON.parse(text);

            console.log(data);
            drawnodes(data,[]);

            /*$( "button" ).click(function(e) {
                var thisbtnname = $(this).text();
                var result = localStorage.getItem(thisbtnname);
                console.log( "Handler for .click() called.",thisbtnname.length,$(this).text(),result,$("#tagname").val() );
                //localStorage.setItem(thisbtnname, $("#tagname").val());
                for (elem in datafilter){
                    if (datafilter[elem]=="CInBridgeUp"){console.log("data:",elem);}
                    colorsbtn=datafilter[$(this).text()];
                    $("#nodelist").html("");
                    displayed=[];
                    for (elem in values) {

                        var newelem = createNode(elem, values[elem]);
                        $("#nodelist").last().append(newelem);
                    }
                //break

            }

            });*/

        });
        $("area").click(function(e){
            e.stopPropagation();
            console.log(e.target.id);
            applyinputfilter(e.target.id);
            $("#filterval").text(e.target.id)
        });





});








function createRow(name,nodeParams){
    var newRow = $("<div class='insert'></div>");
    var bcolor=" btn-success";


    for (var j=0;j<4;j++){
        var groupnode = $("#grouprow").clone();
        groupnode.attr('id',j+name).removeAttr('hidden')
        var newcellin = $("<button>", {"class": "btn "+bcolor+" btn-sm btn-block"}).html(name);
            groupnode.find(".fctin").append(newcellin);
        var newcellfct = $("<button>", {"class": "btn "+bcolor+" btn-sm btn-block"}).html("2<br>2<br>2<br>");
            groupnode.find(".fctfcts").append(newcellfct);
        var newcellout = $("<button>", {"class": "btn "+bcolor+" btn-sm btn-block"}).html("3<br>");
            groupnode.find(".fctout").append(newcellout);
        newRow.find(".insert").append(groupnode);
    }
    return newRow;
}
