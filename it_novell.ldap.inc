<?php

/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 *  Ищем чего либо в LDAP
 * 
 * @param type $dn
 * @param type $filter
 * @return boolean
 */
function it_novell_ldap_search($dn, $filter) {
  $dbg = 0;
//  $dn = 'ou=Internet_Proxy,ou=ACCESS,o=MCB';
//  $condition = 'objectClass=groupOfNames';
  if ($ldap_servers = ldap_servers_get_servers('metkom_novell', 'enabled')) {
    // Get first server.
    $ldap_server = current($ldap_servers);
    // Run a search.
    if ($results = $ldap_server->search($dn, $filter)) {
      $dbg = 5;
    }
    else {
      drupal_set_message(t('No results for that query.'));
      $results = FALSE;
    }
  }
  else {
    drupal_set_message(t('LDAP connection error. Please contact an Administrator.'));
    $results = FALSE;
  }
  return $results;
}