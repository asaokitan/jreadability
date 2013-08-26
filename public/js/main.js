////////////////////////////////////////////////////////////
// メイン関数
// Version: 0.1.0
// Author: Yoichiro Hasebe
// Modified: 2013/08/26
////////////////////////////////////////////////////////////

$(function(){
	var subdir = $('#current_mode').attr("subdir")

  $.getScript(subdir + "/js/hinshi_chart.js", function(){});
  $.getScript(subdir + "/js/goshu_chart.js", function(){});
  $.getScript(subdir + "/js/mojishu_chart.js", function(){});
  $.getScript(subdir + "/js/textdata_table.js", function(){});
  $.getScript(subdir + "/js/vocabdata_table.js", function(){});

  function allclear(){
    $("#table_statistics").empty();
    $("#table_hinshi").empty();
    $("#table_goshu").empty();
    $("#table_mojishu").empty();
    $("#hinshi_chart").empty();
    $("#goshu_chart").empty();
    $("#mojishu_chart").empty();
    $('#textdata_table').empty();
    $("#vocabdata_tbody").empty();    
    $("#textdata").hide();
    $("#vocabdata").hide();
  }

  // 使用方法タブの動作
  $("#usage_link").click(function(){
    $("#usage").show();
    $("#info").hide();
    $("#textdata").hide();
    $("#vocabdata").hide();
		$('#current_mode').attr("mode", "usage");		
  })

  // テキスト情報タブの動作
  $("#info_link").click(function(){
    // $("#info_link").show();
    $("#usage").hide();
    $("#info").show();
    $("#textdata").hide();
    $("#vocabdata").hide();
		$('#current_mode').attr("mode", "info");
  })

  // テキスト詳細タブの動作
  $("#textdata_link").click(function(){
    // $("#textdata_link").show();
    $("#usage").hide();
    $("#info").hide();
    $("#vocabdata").hide();
    $("#textdata").show();
		$('#current_mode').attr("mode", "textdata");
  })

  // 語彙リストタブの動作
  $("#vocab_link").click(function(){
    // $("#vocab_link").show();
    $("#usage").hide();
    $("#info").hide();
    $("#textdata").hide();
    $("#vocabdata").show();
		$('#current_mode').attr("mode", "vocabdata");
  })
  
  // 開始時は使用法用タブだけをアクティブに
  allclear();
  $("#info_link").hide();    
  $("#textdata_link").hide();    
  $("#vocab_link").hide();    
  $("#usage_link").click();   
  	
  // 「実行」ボタン押し下げ時の動作
  $('#execute').click(function() {
		var subdir = $('#current_mode').attr("subdir")
    var text   = $('#text').val();

    var if_textdata = $('#if_textdata').is(':checked');
    var if_vocabdata = $('#if_vocabdata').is(':checked');
    var kakko  = $('#kakko').is(':checked');
    var aozora = $('#aozora').is(':checked');
    $("#message").show();
    $("#message").attr("class", "label label-default").html("処理中");
    
    $.ajax({
      type: 'post',
      url: subdir + '/get_info',
      data: {
        text: text,
        if_textdata: if_textdata,
        if_vocabdata: if_vocabdata,
        kakko: kakko,
        aozora: aozora
      },
      // 戻り値が複数になるのでjsonにまとめて送ってもらう
      dataType: 'json',
      // jreadability.rbのget_infoメソッドから値が返される

      success: function(data){

        allclear();
        
        if(data.check != "true"){
          $("#message").attr("class", "label label-warning").html(data.check);
          $("#usage_link").click          
          return false;
        }

				var current_mode = $('#current_mode').attr("mode");
        $('#info_link').click();

		    $("#info_link").show();				
        if(if_vocabdata == true){
          $("#vocab_link").show(); 
        } else {
          $("#vocab_link").hide(); 
        }
        if(if_textdata == true){
          $("#textdata_link").show(); 
        } else {
          $("#textdata_link").hide(); 
        }
				
        create_hinshi_chart(data.hinshi_chart_json);
        create_goshu_chart(data.goshu_chart_json);
        create_mojishu_chart(data.mojishu_chart_json);

        $('#table_statistics').append(data.statistics);
        $('#table_hinshi').append(data.hinshi_breakdown);
        $('#table_goshu').append(data.goshu_breakdown);
        $('#table_mojishu').append(data.mojishu_breakdown);

				if(if_textdata){
          $('#textdata_table').append(data.textdata);
          create_textdata_table(data.num_sentences_total, data.sentence_length);
				}

				if(if_vocabdata){
          create_vocabdata_table(data.vocabdata_json, data.num_morpheme_total, "hatsuon");
				}
				
				if(current_mode === "textdata" && if_textdata){
          $('#textdata_link').click();
				} else if(current_mode == "vocabdata" && if_vocabdata){
          $('#vocab_link').click();					
				}
				        
        $("#message").attr("class", "label label-success").html("処理に成功しました");
      },

	    complete : function() {
        setTimeout(function(){
          $("#message").attr("class", "label label-primary").html("日本語テキストを入力");
        }, 2000);        
      }
    });
  });
  
  // 「クリア」ボタン押し下げ時の動作
  $('#clear').click(function() {    
    allclear();
    $("#info_link").hide();    
    $("#textdata_link").hide();    
    $("#vocab_link").hide();        
    $('#text').val("");    
    $('#usage_link').click();    
  });

})