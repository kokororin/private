<?php
$str = file_get_contents('README.src.md');

$commands = json_decode(file_get_contents('Default.sublime-commands'), true);

$passes = explode(PHP_EOL, trim(`php fmt.phar --list-simple`));

$strCommands = implode(PHP_EOL,
	array_map(function ($v) {
		return ' *  ' . $v['caption'];
	}, $commands)
);

$strPasses = implode(PHP_EOL,
	array_map(function ($v) {
		return ' * ' . $v;
	}, $passes)
);

file_put_contents('README.md',
	strtr($str, [
		'%CMD%' => $strCommands,
		'%PASSES%' => $strPasses,
	])
);