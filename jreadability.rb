#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

#########################################################
# 次のことをするSinatraアプリ
# 1. Mecab+Unidicを用いて日本語テキストのリーダビリティを算出
# 2. 様々な形式で入力されたテキストに関する情報を表示
# 2. jvocabulary.db から語彙の辞書的情報を取得して表示
# Version: 0.1.0
# Author: Yoichiro Hasebe
# Modified: 2013/08/26
#########################################################

$LOAD_PATH << File.dirname(__FILE__)
$LOAD_PATH << File.dirname(__FILE__) + "/lib"

require 'config'
require 'json'
require 'analyzer'
require 'jvocabulary'
require 'helpers'

# 開発モードであればサーバの再起動無しで変更を反映
if development?
  require 'sinatra/reloader'
end

#  ホームディレクトリではindexページを表示
get '/' do
  @max_num_characters = $MAX_NUM_CHARACTERS
  @settings_data = make_settings_table()
  erb :index
end

# 「実行」ボタン押し下げ時の処理
post '/get_info' do
  text   = params[:text]
  if text.size > $MAX_NUM_CHARACTERS
    return {:check => "テキストが#{$MAX_NUM_CHARACTERS}字を超えています（#{text.size}文字）"}.to_json
  end

  if_textdata  = params[:if_textdata] == "true"  ? true : false
  if_vocab  = params[:if_vocab] == "true"  ? true : false
  kakko  = params[:kakko] == "true"  ? true : false
  aozora = params[:aozora] == "true" ? true : false
  analyzer = Analyzer.new(kakko, aozora)
  analyzer.execute(text)
  
  if analyzer.morphs.empty?
    return {:check => "処理可能なテキストが入力されていません"}.to_json
  end
  
  statistics = make_statistics(analyzer)

  num_sentences_total = analyzer.dataset[:num_sentences]
  sentence_length = analyzer.dataset[:avg_num_of_words]

  hinshi_data = make_hinshi_data(analyzer)
  goshu_data = make_goshu_data(analyzer)
  mojishu_data = make_mojishu_data(analyzer)

  data = {:statistics => statistics, 
          :hinshi_breakdown => make_hinshi_table(hinshi_data), :hinshi_chart_json => hinshi_data.to_json,
          :mojishu_breakdown => make_mojishu_table(mojishu_data), :mojishu_chart_json => mojishu_data.to_json,
          :goshu_breakdown => make_goshu_table(goshu_data), :goshu_chart_json => goshu_data.to_json, 
          :num_morpheme_total => analyzer.morphs.size, :num_sentences_total => num_sentences_total,
          :sentence_length => sentence_length, :num_characters => text.size, 
          :settings => settings, :check => "true"}

  data[:textdata] = make_textdata(analyzer) if if_textdata
  data[:vocabdata_json] = make_vocabdata(analyzer) if if_vocab
  
  return data.to_json
end

# テキスト詳細タブなどで形態素がクリックされた際の処理
post '/get_morphdata' do
  jv = Jvocabulary.new
  jv.connect

  # まずは基本形と分類情報でトライ
  morphs = jv.get_vocab_with_kihonkei(params[:kihonkei], params[:feature])

  # だめなら読みと分類情報で
  if morphs.empty?
    morphs = jv.get_vocab_with_yomi(params[:yomi], params[:feature])  
  end

  jv.disconnect
  
  if !morphs.empty?
    morph = morphs.first

    result = "<p><b>発　音：</b>#{morph[:yomi]}</p>" +
      "<p><b>分　類：</b>#{morph[:feature]}</p>" +
      "<p><b>語彙レベル：</b>#{morph[:level]}</p>" +
      "<p><b>語　種：</b>#{morph[:category]}</p>"
    meanings = morph[:meanings].split("\n")
    usages = morph[:usages].split("\n")
    details = []
    meanings.size.times do |i|
      detail = "<p><b>語義 #{i + 1}：</b>" + meanings[i] + "<br />"
      detail += "<b>用　例：</b>" + usages[i] + "</p>" if usages[i]
      details << detail
    end
    result += details.join
  end
end

