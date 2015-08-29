Strict

Class MapCloner<T>
	Function Clone:T(_map:T)
		Local map:T = New T()
		For Local kv:= EachIn _map
			map.Add(kv.Key, kv.Value)
		Next
		Return map
	End
End