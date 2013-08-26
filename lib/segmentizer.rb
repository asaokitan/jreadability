#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

###########################################################
# 日本語テキストから段落と文を切り出すためのクラス
# Version: 0.1.0
# Author: Yoichiro Hasebe
# Modified: 2013/08/26
###########################################################

# 段落の分割マーカーは全角または半角スペース
# ただし空行も段落のマーカーとする
PARAGRAPH_SEPARATORS = ['^　', '^ ', '\n\n+']
PARAGRAPH_REGEXP = Regexp.compile("(?:" + PARAGRAPH_SEPARATORS.join("|") + ")+", Regexp::MULTILINE)

# 文の分割マーカーは「。」「．」「？」「！」（いずれも全角）
# それぞれの後に全角スペースが挿入されている可能性を想定
SENTENCE_SEPARATORS = ['。　?', '．　?', '？　?', '！　?']
SENTENCE_REGEXP = Regexp.compile("(?:" + SENTENCE_SEPARATORS.join("|") + ")", Regexp::MULTILINE)

OPENING_QUOTATIONS = ['「', '（', '『']
CLOSING_QUOTATIONS = ['」', '）', '』']

class Segmentizer
  attr_accessor :text

  def initialize
    @text = ""
  end
    
  # テキストを読み込み
  def load_text(text) 
    @text = text
  end
      
  # ファイルオブジェクトから読み込み
  def load_file(file)
    @text = file.read
  end
  
  # 段落の分割実行
  def paragraphs
    # 前後の空白を除去
    text_mod = @text.clone
    text_mod.slice!(/\A[　 ]*/m)
    text_mod.slice!(/[　 ]*\z/m)
    paras = text_mod.split(PARAGRAPH_REGEXP)

  end
  
  # 文の分割実行
  def sentences
    
    results = []

    # 段落ごとに実行
    paragraphs.each do |para|
    
      # 前後の空白を除去
      para.slice!(/\A[　 ]*/m)
      para.slice!(/[　 ]*\z/m)
        
      # 文分割マーカーで分割
      sents = para.split(SENTENCE_REGEXP)
            
      # 文の前後の引用符、改行文字、段落記号等を削除
      sents.map! do |sent|
        # 行頭の引用符（クローズ）を削除（マーカーに基づく文分割により発生）
        sent = sent.sub(/\A(?:#{CLOSING_QUOTATIONS.join("|")}|\s)+/, "")

        # 対応の取れていない引用符の検出
        oq = sent.scan(/(?:#{OPENING_QUOTATIONS.join("|")})/)
        cq = sent.scan(/(?:#{CLOSING_QUOTATIONS.join("|")})/)        
        diff = oq.size - cq.size
        
        case
        when diff == 0
        when diff > 0
          diff.times do
            sent = sent.sub(/\A.*?(?:\s|#{OPENING_QUOTATIONS.join("|")})+/, "")
          end
        when diff < 1
          (-diff).times do
            sent = sent.sub(/\A.*(?:#{CLOSING_QUOTATIONS.join("|")}|\s)+/, "")
          end
        end
        sent        
      end   
       
      # 空白文字だけの文は除外
      sents.delete_if do |sent|
        /\A\s*\z/ =~ sent
      end
      results += sents
    end
    results    
  end
  
end

##### Test Code #####

# seg = Segmentizer.new(true)
# kokoro = File.open(File.dirname(__FILE__) + "/../data/kokoro.txt")
# seg.load_file(kokoro)
# kokoro.close
# paragraphs = seg.paragraphs
# sentences = seg.sentences
# 
# puts "The data has #{paragraphs.size} paragraphs."
# puts "The data has #{sentences.size} sentences."
# puts "\n"
# 
# paragraphs.each_with_index do |paragraph, idx|
#   puts "---------- Paragraph ##{idx + 1} ----------"
#   puts paragraph
# end
# 
# puts "\n"
# 
# sentences.each_with_index do |sentence, idx|
#   puts "---------- Sentence ##{idx + 1} ----------"
#   puts sentence
# end
# 
# __END__
# 気象庁は２３日午前５時ごろ、東北地方から西日本にかけての大雨と雷、突風に関する気象情報を発表した。
# 　それによると、東北地方と東日本では２４日にかけ、１時間に５０ミリから６０ミリの非常に激しい雨が降る恐れがあり、同日は九州北部地方でも、１時間に５０ミリの非常に激しい雨が降る恐れ。気象庁は、低い土地の浸水や河川増水、落雷、竜巻などに対する警戒を呼びかけている。