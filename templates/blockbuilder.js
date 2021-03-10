/**
 * Created by eric.baril on 2021-02-23.
 */
function createNode(name,nodeParams) {
    var newNode = $("#template").clone();
    newNode.attr('id',name).removeAttr('hidden')

    var cnt=0;
    /* Create Inputs elements */
    var inputGroups=[];
    var OutputGroups=[];
    var displayed=[];
    var groupsobj={};


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
            }
        }
    }


    for (elem in inputGroups) {
        newNode.find(".fctin").append("<br>"+inputGroups[elem]);
        //console.log(groupsobj,inputGroups[elem]);

        for (var i=0;i<groupsobj[inputGroups[elem]].length;i++){
            var bcolor='btn-light';
            if (Object.keys(datafilter).includes(elem)){bcolor='btn-success'};
            var newcellin = $("<button>", {"class": "btn "+bcolor+" btn-sm btn-block"}).html(groupsobj[inputGroups[elem]][i] + "<br>");
            newNode.find(".fctin").append(newcellin);
            displayed.push(groupsobj[inputGroups[elem]][i])
        }
    }


    for (elem in nodeParams["Inputs"]) {
         //console.log("localstorage:",localStorage.getItem("lastname"));
        newNode.find(".fctin").append("<br>"+elem);

        for (subelem in nodeParams["Inputs"][elem]) {
            var bcolor='btn-secondary';

            //if (Object.keys(outfilter).includes(elem)){bcolor='btn-success'};
            //if (Object.keys(datafilter).includes(elem)){bcolor='btn-success'};

            if(!displayed.includes(subelem)){
                 var newcellin = $("<button>", {"class": "btn "+bcolor+" btn-sm btn-block"}).html(subelem + "<br>");
                newNode.find(".fctin").append(newcellin);
            }

        }
    }





    /* Create Mid section for fcts list elements */
    var midnode=$('<p/>').html('<h1><p class="text-center align-middle"><br>'+name+'<br></p></h1>');
    newNode.find(".fctcmd").append(midnode);

    newNode.find(".fctfcts").append("Sub-Functions<br>");
    for (elem in nodeParams["fcts"]) {
        var bcolor='btn-secondary';
        var newcellfct = $("<button>", {"class": "btn "+bcolor+" btn-sm btn-block"}).html(nodeParams["fcts"][elem] + "<br>");
        newNode.find(".fctfcts").append(newcellfct);

    }

    /* Create Outputs elements */
    for (elem in nodeParams["Outputs"]) {
        for (subelem in nodeParams["Outputs"][elem]) {
            var thistag= localStorage.getItem(subelem);
            if (thistag != "") {
                if (! OutputGroups.includes(thistag)) {
                    OutputGroups.push(thistag);
                    groupsobj[thistag]=[];
                }
                groupsobj[thistag].push(subelem);
            }

        }
    }

    for (elem in OutputGroups) {
        newNode.find(".fctout").append("<br>"+OutputGroups[elem]);

        for (var i=0;i<groupsobj[OutputGroups[elem]].length;i++){
            var bcolor='btn-secondary';
            var btnname = groupsobj[OutputGroups[elem]][i] + "<br>"
            var newcellin = $("<button>", {"class": "btn "+bcolor+" btn-sm btn-block"}).html(btnname);
            newNode.find(".fctout").append(newcellin);
            displayed.push(groupsobj[OutputGroups[elem]][i])
        }
    }

    for (elem in nodeParams["Outputs"])    {
        newNode.find(".fctout").append("<br>"+elem);
        for (subelem in nodeParams["Outputs"][elem]){
            var bcolor='btn-secondary';

            if(!displayed.includes(subelem)){
                var newcellout = $("<button>",{"class":"btn "+bcolor+" btn-sm btn-block"}).html(subelem+"<br>");
                newNode.find(".fctout").append(newcellout);
            }


        };
    }
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

/*function download(content, fileName, contentType) {
    var a = document.createElement("a");
    var file = new Blob([content], {type: contentType});
    a.href = URL.createObjectURL(file);
    a.download = fileName;
    a.click();
}*/


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