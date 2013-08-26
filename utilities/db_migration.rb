#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

###########################################################
# CSV/TSVから語彙情報を取得し、SQLITEに格納する
# Version: 0.1.0
# Author: Yoichiro Hasebe
# Modified: 2013/08/26
###########################################################

$LOAD_PATH << File.dirname(__FILE__) + "/../"
$DB_PATH = File.expand_path(File.dirname(__FILE__) + "/data/jvocabulary.db")

require 'sequel'
require 'progressbar'
require 'csv'

##### DB・テーブル作成 #####
dir = File.dirname(__FILE__)
options = {}
File.unlink($DB_PATH)
DB = Sequel.sqlite($DB_PATH)
DB.pragma_set("SYNCHRONOUS", :off)
DB.pragma_set("JOURNAL_MODE", :off)
DB.pragma_set("CACHE_SIZE", 20000)

DB.drop_table? :surfaces
DB.create_table :surfaces do
  primary_key :id
  String :surface,  :size => 50, :index => true
end

DB.drop_table? :yomis
DB.create_table :yomis do
  primary_key :id
  String :yomi,  :size => 50, :index => true
end

DB.drop_table? :levels
DB.create_table :levels do
  primary_key :id
  Integer :level, :index => true
end

DB.drop_table? :features
DB.create_table :features do
  primary_key :id
  String :feature,  :size => 50, :index => true
end

DB.drop_table? :categories
DB.create_table :categories do
  primary_key :id
  String :category, :size => 50, :index => true
end

DB.drop_table? :jvjoin
DB.create_table :jvjoin do
  primary_key :id
  Integer :surface_id, :index => true
  Integer :yomi_id, :index => true
  Integer :level_id, :index => true
  Integer :feature_id, :index => true
  Integer :category_id, :index => true
  String :meanings
  String :usages
end

DB.drop_view :jvocabulary rescue

##### マイグレーション （CSVの場合）#####
# 元のファイルからデータを読み込み
# headers, *vocab = CSV.read(File.dirname(__FILE__) + "/../data/jvocabulary.csv")

# データ整形
# data = vocab.collect do |row|
#   {:surface  => row[1],
#    :yomi     => row[2],
#    :level    => row[3].slice(/\A\d+/),
#    :feature  => row[4].split(" and "), # 複数ありえるので配列
#    :category => row[5],
#    :meaning  => "",
#    :usages    => ""}
# end

##### マイグレーション （TSVの場合）#####
# 元のファイルからデータを読み込み（TSVの場合）
tsv = File.readlines(File.dirname(__FILE__) + "/../data/jvocabulary.txt")

# 見出し行を削除
tsv.shift

data = tsv.collect do |line|
  colnames = line.split("\t")

  # 元ファイルのidは読み捨てる
  colnames.shift

  cols = {}
  cols[:surface]      = colnames[0]
  cols[:yomi]         = colnames[1]
  cols[:level]        = colnames[2]
  cols[:importance]   = colnames[3]
  cols[:feature]      = colnames[4]
  cols[:category]     = colnames[5]
  cols[:cert_level]   = colnames[6]
  cols[:colloc_info]  = colnames[7]
  cols[:synonym]      = colnames[8]
  cols[:culture]      = colnames[9]
  cols[:accent]       = colnames[10]
  cols[:semantics]    = colnames[11]
  cols[:meaning_1]    = colnames[12]
  cols[:usage_c_1]    = colnames[13]
  cols[:usage_s_1]    = colnames[14]
  cols[:meaning_2]    = colnames[15]
  cols[:usage_c_2]    = colnames[16]
  cols[:usage_s_2]    = colnames[17]
  cols[:meaning_3]    = colnames[18]
  cols[:usage_c_3]    = colnames[19]
  cols[:usage_s_3]    = colnames[20]
  cols[:meaning_4]    = colnames[21]
  cols[:usage_c_4]    = colnames[22]
  cols[:usage_s_4]    = colnames[23]
  cols[:meaning_5]    = colnames[24]
  cols[:usage_c_5]    = colnames[25]
  cols[:usage_s_5]    = colnames[26]
  cols[:meaning_6]    = colnames[27]
  cols[:usage_c_6]    = colnames[28]
  cols[:usage_s_6]    = colnames[29]
  cols[:meaning_7]    = colnames[30]
  cols[:usage_c_7]    = colnames[31]
  cols[:usage_s_7]    = colnames[32]
  cols[:meaning_8]    = colnames[33]
  cols[:usage_c_8]    = colnames[34]
  cols[:usage_s_8]    = colnames[35]
  cols[:meaning_9]    = colnames[36]
  cols[:usage_c_9]    = colnames[37]
  cols[:usage_s_9]    = colnames[38]
  cols[:meaning_10]   = colnames[39]
  cols[:usage_c_10]   = colnames[40]
  cols[:usage_s_10]   = colnames[41]
  cols[:english]      = colnames[42]
  cols[:indonesian]   = colnames[43]
  cols[:tagalog]      = colnames[44]
  cols[:thai]         = colnames[45]
  cols[:variants]     = colnames[46]
  cols
end

##### データ整形 #####
# 語義を1つのテキストにまとめる
data = data.collect do |cols|
  
  surface  = cols[:surface]
  yomi     = cols[:yomi]
  level    = cols[:level].slice(/\A\d+/)
  level    = "*" if(!level || /\A\s*\z/ =~ level)
  feature  = cols[:feature].split(" and ") # 複数ありえるので配列
  category = cols[:category]
  category = "*" if(!category || /\A\s*\z/ =~ category)
  
  m_array = []
  m_array << cols[:meaning_1] unless /\A\s*\z/ =~ cols[:meaning_1]
  m_array << cols[:meaning_2] unless /\A\s*\z/ =~ cols[:meaning_2]
  m_array << cols[:meaning_3] unless /\A\s*\z/ =~ cols[:meaning_3]
  m_array << cols[:meaning_4] unless /\A\s*\z/ =~ cols[:meaning_4]
  m_array << cols[:meaning_5] unless /\A\s*\z/ =~ cols[:meaning_5]
  m_array << cols[:meaning_6] unless /\A\s*\z/ =~ cols[:meaning_6]
  m_array << cols[:meaning_7] unless /\A\s*\z/ =~ cols[:meaning_7]
  m_array << cols[:meaning_8] unless /\A\s*\z/ =~ cols[:meaning_8]
  m_array << cols[:meaning_9] unless /\A\s*\z/ =~ cols[:meaning_9]
  m_array << cols[:meaning_10] unless /\A\s*\z/ =~ cols[:meaning_10]

  meanings = []
  m_array.each_with_index do |meaning, i|
    meanings << meaning
  end
  meanings = meanings.join("\n")

# 用例（作例）を1のテキストにまとめる
  u_array = []
  u_array << cols[:usage_s_1] unless /\A\s*\z/ =~ cols[:usage_s_1]
  u_array << cols[:usage_s_2] unless /\A\s*\z/ =~ cols[:usage_s_2]
  u_array << cols[:usage_s_3] unless /\A\s*\z/ =~ cols[:usage_s_3]
  u_array << cols[:usage_s_4] unless /\A\s*\z/ =~ cols[:usage_s_4]
  u_array << cols[:usage_s_5] unless /\A\s*\z/ =~ cols[:usage_s_5]
  u_array << cols[:usage_s_6] unless /\A\s*\z/ =~ cols[:usage_s_6]
  u_array << cols[:usage_s_7] unless /\A\s*\z/ =~ cols[:usage_s_7]
  u_array << cols[:usage_s_8] unless /\A\s*\z/ =~ cols[:usage_s_8]
  u_array << cols[:usage_s_9] unless /\A\s*\z/ =~ cols[:usage_s_9]
  u_array << cols[:usage_s_10] unless /\A\s*\z/ =~ cols[:usage_s_10]

  usages = []
  u_array.each_with_index do |usage, i|
    usages << usage
  end  
  usages = usages.join("\n")
    
  {:surface   => surface,
   :yomi      => yomi,
   :level     => level,
   :feature   => feature, # 複数ありえるので配列
   :category  => category,
   :meanings  => meanings,
   :usages    => usages}
end

##### プログレスバー準備 #####
prog_bar = ProgressBar.new('data-lines', data.size)

# トランザクションのため、すぐにはDBに書き込まれないので
# 必要なデータのIDを格納しておくハッシュを用意
surface_hash = {}
yomi_hash = {}
level_hash = {}
feature_hash = {}
category_hash = {}

##### DBへの書き込み #####
DB.transaction do
  data.each do |data_item|

    surface = data_item[:surface]
    surface_id = surface_hash[surface]
    unless surface_id
      surface_id = DB[:surfaces].insert(:surface => surface)
      surface_hash[surface] = surface_id
    end

    yomi = data_item[:yomi]
    yomi_id = yomi_hash[yomi]
    unless yomi_id
      yomi_id = DB[:yomis].insert(:yomi => yomi)
      yomi_hash[yomi] = yomi_id
    end

    level = data_item[:level]
    level_id = level_hash[level]
    unless level_id
      level_id = DB[:levels].insert(:level => level)
      level_hash[level] = level_id
    end
    
    category = data_item[:category]
    category_id = category_hash[category]
    unless category_id
      category_id = DB[:categories].insert(:category => category)
      category_hash[category] = category_id
    end

    data_item[:feature].each do |feature|
      feature_id = feature_hash[feature]
      unless feature_id
        feature_id = DB[:features].insert(:feature => feature)
        feature_hash[feature] = feature_id
      end

      DB[:jvjoin].insert(:surface_id => surface_id,
      :yomi_id => yomi_id,
      :level_id => level_id,
      :feature_id => feature_id,
      :category_id => category_id,
      :meanings => data_item[:meanings],
      :usages => data_item[:usages]
      )
    end    
    prog_bar.inc
  end
end

##### VIEWの作成 #####
sql =<<SQL
CREATE VIEW jvocabulary AS
SELECT surface, yomi, level, feature, category, meanings, usages FROM jvjoin
INNER JOIN surfaces ON (jvjoin.surface_id = surfaces.id)
INNER JOIN yomis ON (jvjoin.yomi_id = yomis.id)
INNER JOIN levels ON (jvjoin.level_id = levels.id)
INNER JOIN features ON (jvjoin.feature_id = features.id)
INNER JOIN categories ON (jvjoin.category_id = categories.id)
SQL

##### 実行 #####
DB.execute(sql)
prog_bar.finish
puts "DB building completed."