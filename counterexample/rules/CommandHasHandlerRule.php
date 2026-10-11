<?php declare(strict_types = 1);

namespace ResultCacheCounterexample\Rules;

use PhpParser\Node;
use PHPStan\Analyser\Scope;
use PHPStan\Node\InClassNode;
use PHPStan\Reflection\ReflectionProvider;
use PHPStan\Rules\Rule;
use PHPStan\Rules\RuleErrorBuilder;
use function sprintf;
use function str_ends_with;

/**
 * Example of a project-specific rule: every *Command needs a *CommandHandler.
 *
 * @implements Rule<InClassNode>
 */
final class CommandHasHandlerRule implements Rule
{

	public function __construct(private ReflectionProvider $reflectionProvider)
	{
	}

	public function getNodeType(): string
	{
		return InClassNode::class;
	}

	public function processNode(Node $node, Scope $scope): array
	{
		$className = $node->getClassReflection()->getName();
		if (!str_ends_with($className, 'Command')) {
			return [];
		}

		$handler = $className . 'Handler';
		if ($this->reflectionProvider->hasClass($handler)) {
			return [];
		}

		return [
			RuleErrorBuilder::message(sprintf('Command %s has no handler %s.', $className, $handler))
				->identifier('app.commandWithoutHandler')
				->build(),
		];
	}

}
