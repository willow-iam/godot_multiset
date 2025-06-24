extends RefCounted
class_name Multiset
var _items : Dictionary
var _count : int

#Returns a list of distinct items
func unique() -> Array[Variant]: return _items.keys().filter(func(item):return _items[item]>0)
#Returns how much of an item we have
func amount(item:Variant) -> int: return _items.get_or_add(item,0)
func len() -> int: return _count

#If starting_items is a dictionary with nonnegative ints as values, then we can just use those.
#Otherwise, if starting_items isn't such a dictionary, just add all of its items.
func _init(starting_items:Variant=[]) -> void:
	if (starting_items is Dictionary
		and starting_items.values().all(func(n):return typeof(n)==TYPE_INT) #All of the items are ints
		and starting_items.values().all(func(n):return n>=0) #All of the items >= 0 
	):
		_items = starting_items.duplicate()
		_count = starting_items.values().reduce(func(a,b):return a+b,0)
	else:
		_items = Dictionary()
		#I don't check if we actually can iterate through it, because it'll throw an error anyway.
		for item in starting_items:
			add(item)

	
func add(item:Variant,n=1):
	_items[item]=amount(item)+n
	_count+=n

func add_multi(to_add:Multiset):
	for item in to_add.unique():
		add(item,to_add.amount(item))

func remove(item:Variant,n:int=1):
	assert(n>=0)
	#Ensure we have enough of the item to remove
	assert(amount(item)>=n)
	_items[item]-=n
	_count-=n

#Returns the number that wasn't removed
#e.g. If _items["a"] = 3, then remove_up_to("a",5) will set _items["a"] to 0 and return 2
func remove_up_to(item:Variant,n:int=1)->int:
	assert(n>=0)
	if _items.get_or_add(item,0)>=n:
		_items[item]-=n
		_count-=n
		return 0
	else:
		var had = _items[item]
		_items[item]=0
		_count-=had
		return n-had

func remove_random(n:int=1) -> Multiset:
	assert(_count>=n)#Ensure we have enough items to remove
	var removed := Multiset.new()
	for c in n:
		var pseudo_index=randi_range(0,_count-1)
		var item = _iter_get(pseudo_index)
		remove(item)
		removed.add(item)
	return removed

#Returns a dictionary where items:multiset is the removed items
#And unremoved:int is the difference between the number of removed items and the number
func remove_random_up_to(n:int=1) -> Dictionary:
	assert(n>=0)
	var removed := Multiset.new()
	for c in n:
		if _count == 0:
			return {"items":removed,"unremoved":n-c}
		var item = _iter_get(randi_range(0,_count-1))
		remove(item)
		removed.add(item)
	return {"items":removed,"unremoved":0}

func _iter_init(iter: Array) -> bool:
	iter[0] = 0
	return iter[0]<_count

func _iter_next(iter: Array) -> bool:
	iter[0]+=1
	return iter[0]<_count

func _iter_get(iter: Variant) -> Variant:
	#Can't use int for the type hint in _iter_get because it's a builtin.
	assert(iter is int)
	assert(iter < _count)
	var pseudo_index=iter
	var key_index = 0
	var keys = _items.keys()
	while true:
		pseudo_index-=_items[keys[key_index]]
		if pseudo_index<0:
			return keys[key_index]
		else:		
			key_index+=1
	return "unreachable"
	
	
