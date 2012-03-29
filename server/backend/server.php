<?php

$NAMES_DATABASE = 'names.sqlite3';

function exit_with_404($message)
{
  header($_SERVER["SERVER_PROTOCOL"] . ' 404 Not Found');
  exit($message);
}

function connect_to_names_db($filename)
{
  $names_database_filename = dirname(__FILE__) . "/$filename";
  $names_dsn = "sqlite:$names_database_filename";
  $names_db = new PDO($names_dsn);
  return $names_db;
}

function query_names_db_for_name($names_db, $name)
{
  $stmt = $names_db->prepare("SELECT json FROM names WHERE normalized_name = ?");
  $stmt->execute(array($name));
  $result = $stmt->fetchColumn(0);
  return $result;
}

$uri_parts = explode('/', $_SERVER['REQUEST_URI']);
$name = $uri_parts[count($uri_parts) - 1];

if (!preg_match('/([a-z0-9\' ]+)\.json/', $name, $m)) {
  exit_with_404("The requested name, $name, contains invalid characters or is not a JSON request.");
}

$name = $m[1];

header('Content-type', 'application/json; charset=utf-8');

$names_db = connect_to_names_db($NAMES_DATABASE);
$json = query_names_db_for_name($names_db, $name);

if ($json) {
  exit($json);
} else {
  exit_with_404("{}");
}

