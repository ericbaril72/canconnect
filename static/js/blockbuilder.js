/**
 * Created by eric.baril on 2021-02-23.
 */
function createNode(name,nodeParams) {
    var newNode = $("#template").clone();
    newNode.attr('id',name).removeAttr('hidden')

    var cnt=0;
    for (elem in nodeParams["Inputs"]) {
        newNode.find(".fctin").append("<br>"+elem);
        for (subelem in nodeParams["Inputs"][elem]) {
            var bcolor='btn-success';


            if (elem=='G_Variables' | elem=='Parameters'){bcolor='btn-primary'};
            if (nodeParams["Inputs"][elem][subelem]==false){bcolor='btn-danger'}
            var newcellin = $("<button>", {"class": "btn "+bcolor+" btn-lg btn-block"}).html(subelem + "<br>");
            newNode.find(".fctin").append(newcellin);
        }
    }


    var midnode=$('<p/>').html('<h1><p class="text-center align-middle"><br>'+name+'<br></p></h1>');
    newNode.find(".fctcmd").append(midnode);

    newNode.find(".fctfcts").append("Sub-Functions<br>");
    for (elem in nodeParams["fcts"]) {
        var bcolor='btn-secondary';
        var newcellfct = $("<button>", {"class": "btn "+bcolor+" btn-lg btn-block"}).html(nodeParams["fcts"][elem] + "<br>");
        newNode.find(".fctfcts").append(newcellfct);

    }

    for (elem in nodeParams["Outputs"])    {
        newNode.find(".fctout").append("<br>"+elem);
        for (subelem in nodeParams["Outputs"][elem]){
             var bcolor='btn-success';
            if (elem=='Global' ){bcolor='btn-primary'};
            if (nodeParams["Outputs"][elem][subelem]==false){bcolor='btn-danger'}
            var newcellout = $("<button>",{"class":"btn "+bcolor+" btn-lg btn-block"}).html(subelem+"<br>");
            newNode.find(".fctout").append(newcellout);
        };
    }
    return newNode
}



$( document ).ready(function() {
    for (elem in values){


        var newelem =createNode(elem,values[elem]);

        $("#nodelist").append(newelem);

    }
});