////////////////////////////////////////////////////////////
// 語彙リストのテーブルを出力したり、指定の方法でしたりする関数
// Version: 0.1.0
// Author: Yoichiro Hasebe
// Modified: 2013/08/26
////////////////////////////////////////////////////////////

function setup_table(tabledata){
  var tbl_body = "";
  $.each(tabledata, function(i, row) {
    var tbl_row = "";
    $.each(row, function(j, cell) {
      tbl_row += cell;
    })
    tbl_body += "<tr class='contents'>" + tbl_row + "</tr>";
  })

  $("#vocabdata_tbody").html(tbl_body);

  // 列をクリックした時の処理
  $('td.clb').click(function(){
		var subdir = $('#current_mode').attr("subdir")
    var kihonkei = $(this).attr("kihonkei");
    var yomi = $(this).attr("yomi");
    var feature = $(this).attr("feature");
    $.ajax({
      type: 'post',
      url: subdir + '/get_morphdata',
      data: {
        kihonkei: kihonkei,
        yomi: yomi,
        feature: feature
      },
      // 結果が返ってきたらモーダル・ウィンドウに表示
      success: function(data){
        $('#morph-title').text(kihonkei);
        $('#morph-body').html(data);
        $('#morph_data').modal('show');      
      }
    });    
  });
  
  // 列をマウスオーバーでカーソルが変わる
  $('td.clb').css({"cursor":"pointer", "color":"#3071a9"});
  
}

function create_vocabdata_table(vocabdata_json, num_morpheme_total, sort_type){
	var tabledata = JSON.parse(vocabdata_json);
  
  // 形態素数（延べ）を反映
  $('#nobe').text(num_morpheme_total);

  // 形態素数（異なり）を反映
  $('#kotonari').text(tabledata.length);
	
	// メインの情報ページにも反映
	var tr_num_morph_type = "<tr id='tr_num_morph_total'><td>総形態素数（異なり）</td><td>"
	    + tabledata.length + "</td></tr>";
	$('#tr_num_morph_token').after(tr_num_morph_type);

  setup_table(tabledata);
  $('#vocab_shutsugen').css({"color":"IndianRed"})
  $('#sort_shutsugen').attr("disabled", "disabled");
  $('#vocab_hatsuon').css({"color":"Black"})
  $('#sort_hatsuon').removeAttr("disabled");
  $('#vocab_hindo').css({"color":"Black"})
  $('#sort_hindo').removeAttr("disabled");
  $('#vocab_bunrui').css({"color":"Black"})
  $('#sort_bunrui').removeAttr("disabled");
}

function get_tabledata(){
  var newarray = [];
  $.each($('tr.contents'), function(i, row){
    newarray.push([]);
    $.each($(this).children(), function(j, col){
			newarray[i].push($(this).wrap('<p/>').parent().html());
    })
  })
  return newarray;    
}

$("#sort_shutsugen").click(function(){
  var newdata = get_tabledata();
  newdata = newdata.sort(function(a, b){
		a_s = parseInt(a[0].match(/\d+/), 10);
		b_s = parseInt(b[0].match(/\d+/), 10);
    return (a_s==b_s) ? (a[2] > b[2] ? 1 : -1) : (a_s > b_s ? 1 : -1);
  });
  setup_table(newdata);  
  $('#vocab_shutsugen').css({"color":"IndianRed"})
  $('#sort_shutsugen').attr("disabled", "disabled");
  $('#vocab_hindo').css({"color":"Black"})
  $('#sort_hindo').removeAttr("disabled");
  $('#vocab_hatsuon').css({"color":"Black"})
  $('#sort_hatsuon').removeAttr("disabled");
  $('#vocab_bunrui').css({"color":"Black"})
  $('#sort_bunrui').removeAttr("disabled");
})


$("#sort_hatsuon").click(function(){
  var newdata = get_tabledata();
  newdata = newdata.sort(function(a, b){
		a_h = parseInt(a[4].match(/\d+/), 10);
		b_h = parseInt(b[4].match(/\d+/), 10);
    return (a[2]==b[2]) ? (a_h > b_h ? 1 : -1) : (a[2] > b[2] ? 1 : -1);
  });
  setup_table(newdata);  
  $('#vocab_hatsuon').css({"color":"IndianRed"})
  $('#sort_hatsuon').attr("disabled", "disabled");
  $('#vocab_shutsugen').css({"color":"Black"})
  $('#sort_shutsugen').removeAttr("disabled");
  $('#vocab_hindo').css({"color":"Black"})
  $('#sort_hindo').removeAttr("disabled");
  $('#vocab_bunrui').css({"color":"Black"})
  $('#sort_bunrui').removeAttr("disabled");
})

$("#sort_bunrui").click(function(){
  var newdata = get_tabledata();
  newdata = newdata.sort(function(a, b){
		a_h = parseInt(a[4].match(/\d+/), 10);
		b_h = parseInt(b[4].match(/\d+/), 10);
    return (a[3]==b[3]) ? (a_h > b_h ? -1 : 1) : (a[3] > b[3] ? 1 : -1);
  });
  setup_table(newdata);  
  $('#vocab_bunrui').css({"color":"IndianRed"})
  $('#sort_bunrui').attr("disabled", "disabled");
  $('#vocab_hatsuon').css({"color":"Black"})
  $('#sort_hatsuon').removeAttr("disabled");
  $('#vocab_shutsugen').css({"color":"Black"})
  $('#sort_shutsugen').removeAttr("disabled");
  $('#vocab_hindo').css({"color":"Black"})
  $('#sort_hindo').removeAttr("disabled");
})

$("#sort_hindo").click(function(){
  var newdata = get_tabledata();
  newdata = newdata.sort(function(a, b){
		a_h = parseInt(a[4].match(/\d+/), 10);
		b_h = parseInt(b[4].match(/\d+/), 10);
    return (a_h==b_h) ? (a[2] > b[2] ? 1 : -1) : (a_h > b_h ? -1 : 1);
  });
  setup_table(newdata);  
  $('#vocab_hatsuon').css({"color":"Black"})
  $('#sort_hatsuon').removeAttr("disabled");
  $('#vocab_hindo').css({"color":"IndianRed"})
  $('#sort_hindo').attr("disabled", "disabled");
  $('#vocab_shutsugen').css({"color":"Black"})
  $('#sort_shutsugen').removeAttr("disabled");
  $('#vocab_bunrui').css({"color":"Black"})
  $('#sort_bunrui').removeAttr("disabled");
})
