<?php declare(strict_types = 1);

namespace ResultCacheCounterexample;

class Consumer
{

	public function fromTrait(Service $service): int
	{
		return $service->helper();
	}

	public function fromParent(Child $child): int
	{
		return $child->parentHelper();
	}

}
