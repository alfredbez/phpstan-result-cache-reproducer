<?php declare(strict_types = 1);

namespace ResultCacheCounterexample;

trait MissingTrait
{

	public function helper(): int
	{
		return 1;
	}

}
