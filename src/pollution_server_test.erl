%%%-------------------------------------------------------------------
%%% @author paste
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 07. maj 2019 04:02
%%%-------------------------------------------------------------------
-module(pollution_server_test).
-author("paste").

%% API
-include_lib("eunit/include/eunit.hrl").

monitor_prep() ->
  pollution_server:start(),
  pollution_server:addStation("221B Baker Street", {0,0}),
  pollution_server:addStation("Fifth Avenue", {3,4}),
  pollution_server:addValue({0,0}, {{2000,10,10},{12,40,10}}, "PM10", 50),
  pollution_server:addValue("Fifth Avenue", {{2000,10,10},{2,10,10}}, "PM10", 50),
  pollution_server:addValue("221B Baker Street", calendar:local_time(), "PM10", 4),
  pollution_server:addValue("Fifth Avenue", {{2000,10,10},{10,40,10}}, "PM10", 2).

getOneValue_test() ->
  monitor_prep(),
  ?assertEqual(50, pollution_server:getOneValue("Fifth Avenue", {{2000,10,10},{2,10,10}}, "PM10")),
  pollution_server:stop().

getDailyMean_test() ->
  monitor_prep(),
  ?assertEqual(34.0, pollution_server:getDailyMean("PM10", {2000,10,10})),
  pollution_server:stop().

getStationMean_test() ->
  monitor_prep(),
  ?assertEqual(26.0, pollution_server:getStationMean({3,4}, "PM10")),
  pollution_server:stop().

removeValue_test() ->
  monitor_prep(),
  pollution_server:removeValue("Fifth Avenue", {{2000,10,10},{10,40,10}}, "PM10"),
  ?assertEqual(50.0, pollution_server:getStationMean("Fifth Avenue", "PM10")),
  pollution_server:stop().

getMaximumGradientStations_test() ->
  monitor_prep(),
  ?assertEqual({9.6,{3,4},{0,0}}, pollution_server:getMaximumGradientStations()),
  pollution_server:stop().

