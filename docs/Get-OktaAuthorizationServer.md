---
external help file: OktaPosh-help.xml
Module Name: OktaPosh
online version:
schema: 2.0.0
---

# Get-OktaAuthorizationServer

## SYNOPSIS
Get one or more Okta AuthorizationServers

## SYNTAX

### ById
```
Get-OktaAuthorizationServer -AuthorizationServerId <String> [<CommonParameters>]
```

### Query
```
Get-OktaAuthorizationServer [-Query <String>] [-Limit <UInt32>] [-After <String>] [<CommonParameters>]
```

## DESCRIPTION

## EXAMPLES

### EXAMPLE 1
```
PS > Get-OktaAuthorizationServer -Query Reliance
```

Gets authorizations servers with Reliance in the name or description

## PARAMETERS

<!-- #include "./params/query.md" -->
<!-- #include "./params/limit.md" -->
<!-- #include "./params/after.md" -->

<!-- #include "./params/common-parameters.md" -->


## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
