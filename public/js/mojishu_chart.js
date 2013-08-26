////////////////////////////////////////////////////////////
// 文字種の円グラフを出力する関数
// Version: 0.1.0
// Author: Yoichiro Hasebe
// Modified: 2013/08/26
////////////////////////////////////////////////////////////

function create_mojishu_chart(mojishu_chart_json){
  var mojishu_data = JSON.parse(mojishu_chart_json);

  $.jqplot ('mojishu_chart', [mojishu_data], 
    { 
      // title: {
      //     text: '文字種構成',
      //     show: true,
      // },
      grid: {
        background: '#ffffff',
        shadow: false,
        borderWidth: 0
      },
      seriesDefaults: {
        renderer: jQuery.jqplot.PieRenderer, 
        rendererOptions: {
          showDataLabels: true,
          startAngle: -90
        }
      }, 
      legend: {
        show:true,
        location: 'e',
        border: 'none'
      }
    }
  );
}
