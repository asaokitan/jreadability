////////////////////////////////////////////////////////////
// 語種の円グラフを出力する関数
// Version: 0.1.0
// Author: Yoichiro Hasebe
// Modified: 2013/08/26
////////////////////////////////////////////////////////////

function create_goshu_chart(goshu_chart_json){
  var goshu_data = JSON.parse(goshu_chart_json);

  $.jqplot ('goshu_chart', [goshu_data], 
    { 
      // title: {
      //     text: '語種構成',
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
