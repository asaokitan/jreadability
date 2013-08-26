#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

###########################################################
# Mecab/Unidicを使って日本語テキストのリーダビリティを導きだす
# クラスのヘルパー関数群
# Version: 0.1.0
# Author: Yoichiro Hasebe
# Modified: 2013/08/26
###########################################################

helpers do

  # 設定情報の整形
  def make_settings_table
    rows = []
    rows << ["定数", $READABILITY_CONSTANT]
    rows += $READABILITY_FACTORS    
    rows = rows.collect do |r|
      "<tr><td>#{r[0]}</td><td>#{r[1]}</td></tr>"
    end
    settings = "<tbody>\n" +
      rows.join("\n") +
      "</tbody>"
  end
  
  # テキスト統計情報の整形
  def make_statistics(analyzer)
    dataset = analyzer.dataset
    statistics =<<EOD
<tbody>
  <tr><td width='50%'>リーダビリティ・スコア</td><td>#{dataset[:readability_level]}</td></tr>
  <tr><td>ガイドライン</td><td>#{dataset[:guideline]}</td></tr>
  <tr><td>総文数</td><td>#{dataset[:num_sentences]}</td></tr>
  <tr id="tr_num_morph_token"><td>総形態素数（延べ）</td><td>#{dataset[:num_morphemes]}</td></tr>
  <tr><td>総文字数<small>（記号・空白を含む）</small></td><td>#{dataset[:num_characters]}</td></tr>
  <tr><td>一文の平均語数</td><td>#{dataset[:avg_num_of_words]}</td></tr>
</tbody>
EOD
  end

  # 品詞構成のテーブルおよび円グラフ用データを作成
  def make_hinshi_data(analyzer)
    dataset = analyzer.dataset
    pos_data = []
    pos_data << ['形状詞', dataset[:keijoushi]]
    pos_data << ['形容詞', dataset[:keiyoushi]]
    pos_data << ['助詞', dataset[:joshi]]
    pos_data << ['助動詞', dataset[:jodoushi]]
    pos_data << ['接続詞', dataset[:setsuzokushi]]
    pos_data << ['代名詞', dataset[:daimeishi]]
    pos_data << ['動詞', dataset[:doushi]]
    pos_data << ['副詞', dataset[:fukushi]]
    pos_data << ['固有名詞', dataset[:koyuumeishi]]
    pos_data << ['普通名詞', dataset[:futsuumeishi]]
    pos_data << ['連体詞', dataset[:rentaishi]]
    pos_data.sort_by! {|pos| -pos[1] }
    
    chart_data = []
    pos_data.each do |pos|
      chart_data << [pos[0], pos[1]] unless pos[1] == 0
    end
    pos_data.sort_by{|p| -p[1]}
    other = analyzer.morphs.size - pos_data.transpose[1].inject(:+)    
    chart_data << ['その他', other] unless other == 0
    chart_data
  end

  # 品詞構成のテーブルを作成
  def make_hinshi_table(data)
    "<tbody>\n" +
    data.collect{ |r|"<tr><td>#{r[0]}</td><td>#{r[1]}</td></tr>" }.join("\n") +
    "</tbody>\n"
  end
  
  # 語種構成のテーブルおよび円グラフ用データを整形
  def make_goshu_data(analyzer)
    dataset = analyzer.dataset
    goshu_data = []
    goshu_data << ['和語', dataset[:wago]]
    goshu_data << ['漢語', dataset[:kango]]
    goshu_data << ['外来語', dataset[:gairaigo]]
    goshu_data << ['混種語', dataset[:konshugo]]
    goshu_data << ['定型句', dataset[:teikeiku]]
    goshu_data.sort_by! {|goshu| -goshu[1] }

    chart_data = []
    goshu_data.each do |goshu|
      chart_data << [goshu[0], goshu[1]] unless goshu[1] == 0
    end
  end

  # 語種構成のテーブルを作成
  def make_goshu_table(data)
    "<tbody>\n" +
    data.collect{ |r|"<tbody><tr><td>#{r[0]}</td><td>#{r[1]}</td></tr>" }.join("\n") +
    "</tbody>\n"
  end

  # 文字種構成のテーブルおよび円グラフ用データを作成
  def make_mojishu_data(analyzer)
    dataset = analyzer.dataset
    mojishu_data = []
    mojishu_data << ['漢字', dataset[:kanji]]
    mojishu_data << ['ひらがな', dataset[:hiragana]]
    mojishu_data << ['カタカナ', dataset[:katakana]]
    mojishu_data.sort_by! {|mojishu| -mojishu[1] }

    chart_data = []    
    mojishu_data.each do |mojishu|
      chart_data << [mojishu[0], mojishu[1]] unless mojishu[1] == 0
    end    
  end

  # 文字種構成のテーブルを作成
  def make_mojishu_table(data)
    "<tbody>\n" + 
    data.collect{ |r|"<tr><td>#{r[0]}</td><td>#{r[1]}</td></tr>" }.join("\n") +
    "</tbody>\n"
  end

  # テキスト詳細情報の整形
  def make_textdata(analyzer)
    morphs = analyzer.morphs
    text_data = ""; m_array = []; prev_sent_id = nil
    num_morphs = morphs.size
    
    # 各形態素のテキストをspanの中に埋め込み、yomi属性とfeature属性を付与
    morphs.each do |morph|
      if prev_sent_id && prev_sent_id != morph[:sentence_id]
        m_array = m_array.collect do |morph|
          if morph[:hinshi_daibunrui] == "助詞" || morph[:hinshi_daibunrui] == "助動詞"
            "<span>#{morph[:surface]}</span>"
          else
            "<span class='morph' yomi='#{morph[:hatsuonkei_kihonkei]}' feature='#{morph[:feature]}' kihonkei='#{morph[:shojikei_kihonkei]}' hatsuon_shutsugen='#{morph[:hatsuonkei_shutsugenkei]}' katsuyoukei='#{morph[:katsuyoukei]}' katsuyougata='#{morph[:katsuyougata]}'>#{morph[:surface]}</span>"
          end
        end
        m_str = m_array.join("　")
  	 	  text_data << "<tr><td><span style='font-weight: bold;'>#{prev_sent_id}</span></td><td>#{m_str}</td></tr>\n"
        m_array.clear
      end
      m_array << morph
      prev_sent_id = morph[:sentence_id] 
    end
    m_array = m_array.collect do |morph|
      if morph[:hinshi_daibunrui] == "助詞" || morph[:hinshi_daibunrui] == "助動詞"
        "<span>#{morph[:surface]}</span>"
      else
      "<span class='morph' yomi='#{morph[:hatsuonkei_kihonkei]}' feature='#{morph[:feature]}' kihonkei='#{morph[:shojikei_kihonkei]}' hatsuon_shutsugen='#{morph[:hatsuonkei_shutsugenkei]}' katsuyoukei='#{morph[:katsuyoukei]}' katsuyougata='#{morph[:katsuyougata]}'>#{morph[:surface]}</span>"
      end
    end
    m_str = m_array.join("　")
 	  text_data << "<tr><td><span style='font-weight: bold;'>#{prev_sent_id}</span></td><td>#{m_str}</td></tr>\n"
  end

  # 語彙リストのデータを作成
  def make_vocabdata(analyzer)
    morphs = analyzer.morphs
    vocab = {}
    morphs.each do |morph|
      surface = morph[:surface] || ""
      kihon = morph[:shojikei_kihonkei] || surface
      feature = morph[:feature] || ""
      yomi    = morph[:hatsuonkei_kihonkei] || ""
      
      signature = kihon + "／" + yomi + "：" + feature      
      
      if !vocab[signature]
        vocab[signature] = {surface => 1, :sum => 1}
      else
        if !vocab[signature][surface]
          vocab[signature][surface] = 1
        else
          vocab[signature][surface] += 1
        end
        vocab[signature][:sum] += 1
      end
    end

    total = morphs.size
    tabledata = []      
    shutsugen = 0
    vocab.each do |k, v|
      shutsugen +=1
      listing, feature = k.split("：", 2)
      kihonkei, yomi = listing.split("／", 2)
      sum = v[:sum]
      v.delete(:sum)
      
      variants = v.sort_by {|l, m| [-m, l]}.collect {|n, o| "#{n} (#{o})"}.join(", ")
      percentage = ((sum.to_f / total) * 100).round(2)
      hinshi = feature.split("-").first
      
      # 助詞と助動詞はDBにデータがないのでアンカーを付けない。
      if hinshi == "助詞" || hinshi == "助動詞"
        tabledata << [
          "<td>#{shutsugen}</td><td>#{kihonkei}</td>",
          "<td>#{yomi}</td>", "<td>#{feature}</td>",
          "<td>#{sum}</td>", "<td>#{percentage}</td>", " <td>#{variants}</td>"]          
      else
        tabledata << [
          "<td>#{shutsugen}</td><td class='clb' kihonkei='#{kihonkei}' yomi='#{yomi}' feature='#{feature}'>#{kihonkei}</td>",
          "<td>#{yomi}</td>", "<td>#{feature}</td>",
          "<td>#{sum}</td>", "<td>#{percentage}</td>", " <td>#{variants}</td>"]          
      end
    end
    table_json = tabledata.to_json
  end

end
