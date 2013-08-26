#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

###########################################################
# jvocabulary.db から語彙情報を取得するクラス
# Version: 0.1.0
# Author: Yoichiro Hasebe
# Modified: 2013/08/26
###########################################################

require 'sqlite3'

class Jvocabulary
  def initialize
  end

  def connect
    # DBへの接続
    @db = SQLite3::Database.new($DB_PATH) 
  end

  # DBから情報を取得
  def find_with_kihonkei(kihonkei, feature = nil)
    sql  = "SELECT * FROM jvocabulary\n"
    sql += "WHERE surface = '#{kihonkei}' "
    sql += "AND feature = '#{feature}'" if feature
    sql += ";"
    @db.execute(sql)
  end

  def find_with_yomi(yomi, feature = nil)
    sql  = "SELECT * FROM jvocabulary\n"
    sql += "WHERE yomi = '#{yomi}' "
    sql += "AND feature = '#{feature}'" if feature
    sql += ";"
    @db.execute(sql)
  end

  # DBから取得した情報をハッシュに
  def get_vocab_with_kihonkei(kihonkei, feature = nil)
    data = find_with_kihonkei(kihonkei, feature)
    morphs = []
    data.each do |col|
      morph = {}
      morph[:surface] = col[0]
      morph[:yomi] = col[1]
      morph[:level] = col[2]
      morph[:feature] = col[3]
      morph[:category] = col[4]
      morph[:meanings] = col[5]
      morph[:usages] = col[6]
      morphs << morph
    end
    morphs
  end

  def get_vocab_with_yomi(yomi, feature = nil)
    data = find_with_yomi(yomi, feature)
    morphs = []
    data.each do |col|
      morph = {}
      morph[:surface] = col[0]
      morph[:yomi] = col[1]
      morph[:level] = col[2]
      morph[:feature] = col[3]
      morph[:category] = col[4]
      morph[:meanings] = col[5]
      morph[:usages] = col[6]
      morphs << morph
    end
    morphs
  end

  # DBからの切断
  def disconnect
    @db.close
  end
end

##### Test Code #####
# v = Jvocabulary.new
# v.connect
# results = v.find('コンジョウ')
# p results
# v.disconnect