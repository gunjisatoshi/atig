#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/util'

module Atig
  class Scheduler
    include Util

    def initialize(log, api)
      @log = log
      @api = api
      @agents = []
    end

    def repeat(interval,opts={}, &f)
      t = daemon do
        log :debug, "agent #{t.inspect} is invoked"
        re_try(opts[:retry] || 0){ f.call @api }
        sleep interval
      end

      log :info, "repeat agent #{t.inspect} is registered"
      @agents << t
      t
    end

    def delay(interval, opts={}, &f)
      safe do
        sleep interval
        re_try(opts[:retry] || 0){ f.call @api }
      end
    end

    def re_try(count, &f)
      begin
        f.call
      rescue => e
        log :error, [retry_count, e.inspect].inspect
        if count > 0
          count -= 1
          log :debug, "retry"
          retry
        end
        log :error, "Some Error Happened on Sending #{mesg}. #{e}"
        raise e
      end
    end
  end
end
