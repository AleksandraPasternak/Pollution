%%%-------------------------------------------------------------------
%%% @author paste
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 04. maj 2019 19:20
%%%-------------------------------------------------------------------
-module(pollution_server).
-author("paste").

%% API
-export([start/0, stop/0, call/1, init/0, loop/1]).

-export([addStation/2, addValue/4, removeValue/3, getOneValue/3, getStationMean/2]).
-export([getMaximumGradientStations/0, getDailyMean/2]).

-import(pollution, [createMonitor/0, addStation/3, addValue/5]).
-import(pollution, [removeValue/4, getOneValue/4,getStationMean/3]).
-import(pollution, [getDailyMean/3, getMaximumGradientStations/1]).

%% server

start()->
  register(pollution_server, spawn(pollution_server, init, [])).

init()->
  loop(createMonitor()).

loop(Monitor) ->
  receive
    stop -> stop();
    {Pid, {addStation, Name, Coordinates}}->
      Pid ! {reply, ok},
      loop(pollution:addStation(Name, Coordinates, Monitor));
    {Pid, {addValue, Id, Date, Type, Value}} ->
      Pid ! {reply, ok},
      loop(pollution:addValue(Id, Date, Type, Value, Monitor));
    {Pid, {removeValue, Id, Date, Type}} ->
      Pid ! {reply, ok},
      loop(pollution:removeValue(Id, Date, Type, Monitor));
    {Pid, {getOneValue, Id, Date, Type}} ->
      Pid ! {reply, pollution:getOneValue(Id, Date, Type, Monitor)},
      loop(Monitor);
    {Pid, {getStationMean, Id, Type}} ->
      Pid ! {reply, pollution:getStationMean(Id, Type, Monitor)},
      loop(Monitor);
    {Pid, getMaximumGradientStations} ->
      Pid ! {reply, pollution:getMaximumGradientStations(Monitor)},
      loop(Monitor);
    {Pid, {getDailyMean, TypeMean, Day}} ->
      Pid ! {reply, pollution:getDailyMean(TypeMean, Day, Monitor)},
      loop(Monitor);
    {Pid, {} } ->
      Pid ! {reply, "Wrong command"};
    _ ->
      io:format("Server did nothing. Bye")
  end.

stop()->
  pollution_server ! stop.

%% client

call(Request) ->
  pollution_server ! {self(), Request},
  receive
    {reply, Message} -> Message
  end.

addStation(Name, Coordinates) -> call({addStation, Name, Coordinates}).
addValue(Id, Date, Type, Value) -> call({addValue, Id, Date, Type, Value}).
removeValue(Id, Date, Type) -> call({removeValue, Id, Date, Type}).
getOneValue(Id, Date, Type) -> call({getOneValue, Id, Date, Type}).
getStationMean(Id, Type) -> call({getStationMean, Id, Type}).
getMaximumGradientStations() -> call(getMaximumGradientStations).
getDailyMean(TypeMean, Day) -> call({getDailyMean, TypeMean, Day}).