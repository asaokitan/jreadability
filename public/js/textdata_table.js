////////////////////////////////////////////////////////////
// 入力テキストの詳細データのテーブルを出力する関数
// Version: 0.1.0
// Author: Yoichiro Hasebe
// Modified: 2013/08/26
////////////////////////////////////////////////////////////

function create_textdata_table(num_sentences_total, sentence_length){
  // クリッカブルな形態素の文字色変更またマウスオーバーでカーソル変更
  $('span.morph').css({"cursor":"pointer", "color":"#3071a9"});
  
  // 総文数と1文の平均語数を表示
  $('#num_sentences_total').html(num_sentences_total);
  $('#sentence_length').html(sentence_length);

  // 形態素をクリックしたときの処理
  $('.morph').click(function(){
		var subdir = $('#current_mode').attr("subdir")
    var surface = $(this).text();
    var kihonkei = $(this).attr("kihonkei");
    var feature = $(this).attr("feature");
    var yomi = $(this).attr("yomi");

    var hatsuon_shutsugen = $(this).attr("hatsuon_shutsugen");
    var katsuyoukei = $(this).attr("katsuyoukei");
    var katsuyougata = $(this).attr("katsuyougata");

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
}
