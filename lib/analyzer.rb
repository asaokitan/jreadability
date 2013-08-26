#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

###########################################################
# Mecab/Unidicを使って日本語テキストのリーダビリティを導きだすクラス
# Version: 0.1.0
# Author: Yoichiro Hasebe
# Modified: 2013/08/26
###########################################################

$LOAD_PATH << File.dirname(__FILE__)

require 'segmentizer'
require 'MeCab'
require 'pp'

class Analyzer

  attr_accessor :text, :sentences, :morphs, :dataset

  def initialize(kakko = false, aozora = false)
    @kakko = kakko
    @aozora = aozora
    
    @model = MeCab::Model.new()
    @tagger = @model.createTagger()
    @segmentizer = Segmentizer.new
    @text = ""
    @sentences = []
    @morphs = []
    
    # リーダビリティ産出に必要なデータを格納する変数群
    @dataset = {}
    @dataset[:kandoushi] = 0            # 感動詞-一般
    @dataset[:keijoushi] = 0            # 形状詞
    @dataset[:keiyoushi] = 0            # 形容詞
    @dataset[:joshi] = 0                # 助詞
    @dataset[:jodoushi] = 0             # 助動詞
    @dataset[:setsuzokushi] = 0         # 接続詞
    @dataset[:daimeishi] = 0            # 代名詞
    @dataset[:doushi] = 0               # 動詞
    @dataset[:fukushi] = 0              # 副詞
    @dataset[:koyuumeishi] = 0          # 固有名詞
    @dataset[:futsuumeishi] = 0         # 普通名詞
    @dataset[:rentaishi] = 0            # 連体詞
    @dataset[:num_sentences] = 0        # 総文数
    @dataset[:avg_num_of_words] = 0     # 一文の平均語数（総形態素数／総文数）
    @dataset[:num_morphemes] = 0        # 総形態素数    
  end
  
  # データの集計と計算
  def execute(text)
    reset
    load_text(text)
    segmentize
    @sentences.each do |sentence|
      parse_sentence sentence
    end
    
    # データセットに値を入力
    @dataset[:num_morphemes] = @morphs.size
    @dataset[:num_sentences] = @sentences.size
    @dataset[:avg_num_of_words] = (@morphs.size.to_f / @sentences.size).round(2)
    
    # Mecab+Unidicによる解析結果を集計
    num_sonota = 0
    @morphs.each do |morph|
      case morph[:hinshi_daibunrui]
      when "感動詞"
        @dataset[:kandoushi] += 1 if morph[:hinshi_chuubunrui] == "一般"
      when "形状詞"
        @dataset[:keijoushi] += 1
      when "形容詞"
        @dataset[:keiyoushi] += 1
      when "助詞"
        @dataset[:joshi] += 1
      when "助動詞"
        @dataset[:jodoushi] += 1
      when "接続詞"
        @dataset[:setsuzokushi] += 1
      when "代名詞"
        @dataset[:daimeishi] += 1
      when "動詞"
        @dataset[:doushi] += 1
      when "副詞"
        @dataset[:fukushi] += 1
      when "名詞"
        @dataset[:koyuumeishi] += 1 if morph[:hinshi_chuubunrui] == "固有名詞"
        @dataset[:futsuumeishi] += 1 if morph[:hinshi_chuubunrui] == "普通名詞"
      when "連体詞"
        @dataset[:rentaishi] += 1
      else
        num_sonota += 1
      end
    end

    # 回帰式への当てはめ
    readability_level = $READABILITY_CONSTANT
    factors = $READABILITY_FACTORS.transpose[1]
    @dataset.size.times do |i|
      readability_level += @dataset.values[i] * factors[i]
    end
    
    # 結果にもとづくガイドラインの設定
    case
    when readability_level < 0.3
      guideline = "測定不可"
    when readability_level < 0.7
      guideline = "初級前半"
    when readability_level < 1.8
      guideline = "初級後半"
    when readability_level < 2.4
      guideline = "中級前半"
    when readability_level < 3.4
      guideline = "中級後半"
    when readability_level < 4.4
      guideline = "上級前半"
    when readability_level < 5.5
      guideline = "上級後半"
    else
      guideline = "測定不可"
    end
    
    @dataset[:sonota] = num_sonota
    
    @dataset[:readability_level] = readability_level.round(2)
    @dataset[:guideline] = guideline
    
    # 文字種ごとの数値データ    
    @dataset[:hiragana] = @text.scan(/[ぁ-ん]/).size
    @dataset[:katakana] = @text.scan(/[ァ-ヴ]/).size
    @dataset[:kanji] = @text.scan(/[一-龠]/).size
    
    # 語種ごとの数値データ
    @dataset[:wago] = @morphs.select {|morph| morph[:goshu] == "和"}.size
    @dataset[:kango] = @morphs.select {|morph| morph[:goshu] == "漢"}.size
    @dataset[:gairaigo] = @morphs.select {|morph| morph[:goshu] == "外"}.size
    @dataset[:konshugo] = @morphs.select {|morph| morph[:goshu] == "混"}.size
    @dataset[:teikeiku] = @morphs.select {|morph| morph[:goshu] == "定"}.size
    
    # 平均語数の四捨五入による丸めはreadability_levelに影響するので最後に行う
    @dataset[:avg_num_of_words] = (@morphs.size.to_f / @sentences.size).round(2)
    
    # 総文字数（記号等を含む）
    @dataset[:num_characters] = @text.size
  end  

  # データの表示  
  def show_dataset
    pp @morphs
    pp @dataset
    puts @readability_level
    puts @guideline
  end
    
  ########## 以下はプライベート・メソッド ##########
  private
  
  # データのリセット  
  def reset
    @text = ""
    @sentences.clear
    @morphs.clear
    newdataset = {}
    @dataset.collect do |k, v|
      newdataset[k] = 0
    end
    @dataset = newdataset
    @readability_level = 0
    @guideline = ""
  end

  # テキストの読み込み
  def load_text(text)
    @text = @aozora ? clean_aozora(text) : text
    @text = @kakko ? clean_kakko(@text) : @text
  end

  # 丸括弧内とその内部の文字列を削除
  def clean_kakko(intext)
    outtext = intext.gsub(/（[^）]*）/m, "")
    outtext = outtext.gsub(/\([^\)]*\)/m, "")
  end

  # 青空文庫のメタ情報を除去
  def clean_aozora(intext)
    # 《》：ルビ
    outtext = intext.gsub(/《[^》\n]+》/, "")
    # ｜：ルビの付く文字列の始まりを特定する記号
    outtext = outtext.gsub("｜", "")
    # ［＃］：入力者注　主に外字の説明や、傍点の位置の指定
    outtext.gsub(/［＃[^］]+］/, "")
  end
      
  # 文への分割
  def segmentize
    @segmentizer.load_text(@text)
    @sentences = @segmentizer.sentences
  end
    
  # 文の解析
  def parse_sentence(sentence)
    # センテンスのIDを取得
    # @morphsが空なら、最初のセンテンスとなる
    if @morphs.empty?
      sent_id = 1
    else
      sent_id = @morphs[-1][:sentence_id] + 1
    end
        
    node = @tagger.parseToNode(sentence)
    morphs = []
    morph_id = 0
    while node do
      morph = {:sentence_id => sent_id}
      morph[:surface] = node.surface
      feature = node.feature.split(",")
      morph[:hinshi_daibunrui]  = feature[0]
      # 句読点や記号は飛ばす
      unless (morph[:hinshi_daibunrui] == "記号" ||
              morph[:hinshi_daibunrui] == "補助記号" ||
              morph[:hinshi_daibunrui] == "BOS/EOS")
        # Mecab/Unidicの情報を割り当て
        morph[:hinshi_chuubunrui] = feature[1]
        morph[:hinshi_shoubunrui] = feature[2]
        morph[:hinshi_saibunrui] = feature[3]
        morph[:katsuyougata] = feature[4]
        morph[:katsuyoukei] = feature[5]
        morph[:goi_suyomi] = feature[6]
        morph[:goiso] = feature[7]
        morph[:shojikei_shutsugenkei] = feature[8]
        morph[:hatsuonkei_shutsugenkei] = feature[9]
        morph[:shojikei_kihonkei] = feature[10]
        morph[:hatsuonkei_kihonkei] = feature[11]
        morph[:goshu] = feature[12]
        morph[:gotou_henkagata] = feature[13]
        morph[:gotou_henkakei] = feature[14]
        morph[:gomatsu_henkagata] = feature[15]
        morph[:gomatsu_henkakei] = feature[16]
        morph_id += 1
        morph[:morph_id] = morph_id
        # DBからの情報を割り当て
        fkey = [morph[:hinshi_daibunrui], morph[:hinshi_chuubunrui], morph[:hinshi_shoubunrui],
                morph[:saibunrui4]].delete_if{|i| i == "*"}.compact.join("-")
        morph[:feature] = fkey
        morphs << morph
      end
      node = node.next
    end
    @morphs += morphs
  end
end

##### Test Code #####
# analyzer = Analyzer.new
# text = DATA.read
# DATA.close
# analyzer.execute(text)
# analyzer.show_dataset
# 
# __END__
# 太郎は次郎が新しい服を買ったと花子に言った。