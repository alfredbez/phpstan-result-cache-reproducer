<?php declare(strict_types = 1);

namespace ResultCacheCounterexample;

class MissingParent
{

	public function parentHelper(): int
	{
		return 2;
	}

}
