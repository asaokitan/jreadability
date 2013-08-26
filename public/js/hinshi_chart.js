////////////////////////////////////////////////////////////
// 品詞の円グラフを出力する関数
// Version: 0.1.0
// Author: Yoichiro Hasebe
// Modified: 2013/08/26
////////////////////////////////////////////////////////////

function create_hinshi_chart(hinshi_chart_json){
  var hinshi_data = JSON.parse(hinshi_chart_json);

  $.jqplot ('hinshi_chart', [hinshi_data], 
    { 
      // title: {
      //     text: '品詞構成',
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
