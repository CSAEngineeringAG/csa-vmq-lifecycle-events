-module(vmq_lifecycle_events).
-behaviour(on_register_hook).
-behaviour(on_register_m5_hook).
-behaviour(on_client_offline_hook).
-behaviour(on_client_gone_hook).

-export([on_client_gone/1, on_client_offline/1,
	 on_register_m5/4, on_register/3]).

publish_client_status(SubscriberId, Status, Payload) ->
    {ok, {M, F, A}} = application:get_env(vmq_lifecycle_events, registry_mfa),
    {_, PublishFun, {_, _}} =	apply(M, F, A), 
    ClientId = subscriber_id(SubscriberId),
    Topic = [<<"$SYS">>, list_to_binary(atom_to_list(node())), <<"clients">>, ClientId, Status],
    PublishFun(Topic, Payload, #{qos => 1, retain => false}), 
    ok.

publish_client_connect(SubscriberId, Peer, UserName) ->
    Payload = jsx:encode([{<<"peer">>, list_to_binary(inet:ntoa(Peer))}, {<<"username">>, UserName}]),
    publish_client_status(SubscriberId, <<"connected">>, Payload),
    ok.

publish_client_disconnect(SubscriberId, Reason) -> 
    Payload = jsx:encode([{<<"reason">>, Reason}]),
    publish_client_status(SubscriberId, <<"disconnected">>, Payload),
    ok.

on_register({Peer, _}, SubscriberId, UserName) ->
     publish_client_connect(SubscriberId, Peer, UserName), ok.

on_register_m5({Peer, _}, SubscriberId, UserName, _) ->
    publish_client_connect(SubscriberId, Peer, UserName), ok.

on_client_offline(SubscriberId) ->
    publish_client_disconnect(SubscriberId, <<"offline">>), ok.

on_client_gone(SubscriberId) ->
    publish_client_disconnect(SubscriberId, <<"gone">>), ok.

subscriber_id({_, ClientId}) -> binary_to_list(ClientId).