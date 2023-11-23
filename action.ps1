# HelloID-Task-SA-Target-Jira-TicketUpdateStatus
################################################
# Form mapping
$formObject = @{
    ticketId = $form.ticketId
    transitionId = $form.transitionId
}

try {
    Write-Information "Executing Jira action: [TicketUpdateStatus] for: [$($formObject.ticketId)]"
    $auth = $($JiraUserName) + ':' + $($JiraApiToken)
    $encoded = [System.Text.Encoding]::UTF8.GetBytes($auth)
    $authorization = [System.Convert]::ToBase64String($Encoded)

    $ticketUpdateBody = @{
        transition = @{
            id = $formObject.transitionId
        }
    } | ConvertTo-Json

    $splatParams = @{
        Uri         = "$($JiraBaseUrl)/rest/api/latest/issue/$($formObject.ticketId)/transitions"
        Method      = 'POST'
        ContentType = 'application/json'
        Body        = ([System.Text.Encoding]::UTF8.GetBytes(($ticketUpdateBody | ConvertTo-Json)))
        Headers     = @{
            'Authorization' = "Basic $($authorization)"
        }
    }
    $response = Invoke-RestMethod @splatParams

    $auditLog = @{
        Action            = 'UpdateResource'
        System            = 'Jira'
        TargetIdentifier  = $response.id
        TargetDisplayName = $form.ticketId
        Message           = "Jira action: [TicketUpdateStatus] for: [$($formObject.ticketId)] executed successfully"
        IsError           = $false
    }
    Write-Information -Tags 'Audit' -MessageData $auditLog
    Write-Information "Jira action: [TicketUpdateStatus] for: [$($formObject.ticketId)] executed successfully"
} catch {
    $ex = $_
    $auditLog = @{
        Action            = 'UpdateResource'
        System            = 'Jira'
        TargetIdentifier  = $form.ticketId
        TargetDisplayName = $form.ticketId
        Message           = "Could not execute Jira action: [TicketUpdateStatus] for: [$($formObject.ticketId)], error: $($ex.Exception.Message)"
        IsError           = $true
    }
    if ($($ex.Exception.GetType().FullName -eq "Microsoft.PowerShell.Commands.HttpResponseException")) {
        $auditLog.Message = "Could not execute Jira action: [TicketUpdateStatus], error: $($ex.ErrorDetails.Message)"
        Write-Error "Could not execute Jira action: [TicketUpdateStatus], error: $($ex.ErrorDetails.Message)"
    } else {
        Write-Information -Tags "Audit" -MessageData $auditLog
        Write-Error "Could not execute Jira action: [TicketUpdateStatus], error: $($ex.Exception.Message)"
    }
}
########################################
