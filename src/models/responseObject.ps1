class ResponseObject {
    [System.Net.HttpListenerResponse]$HttpResponse
    [string]$FilePath
    [string]$ResponseString
    [string]$ResponseType
    [string]$ContentType

    ResponseObject([System.Net.HttpListenerResponse] $response) {
        $this.HttpResponse = $response
        $this.HttpResponse.Headers.Add("Access-Control-Allow-Origin", "*")
        $this.HttpResponse.Headers.Add("Access-Control-Allow-Headers", "Content-Type")
        $this.HttpResponse.StatusCode = 200
    }

    [void] Respond() {
        $ResponseBuffer = @()
        switch ($this.ResponseType) {
            "json" {
                $this.ContentType = "application/json"
            }
            "html" {
                $this.ContentType = "text/html"
            }
            "binary" {
                $this.ContentType = "application/octet-stream"
            }
            Default {}
        }

        try {
            if ($this.ResponseString -and $this.ResponseString.Length -gt 0) {
                $ResponseBuffer = [System.Text.Encoding]::UTF8.GetBytes($this.ResponseString)
            } elseif ($this.filepath) {
                $ResponseBuffer = [System.IO.File]::ReadAllBytes($this.FilePath)
            } else {
                $this.HttpResponse.StatusCode = 404
            }

            if ($ResponseBuffer.Length -gt 0) {
                $this.HttpResponse.ContentLength64 = $ResponseBuffer.Length
                $this.HttpResponse.OutputStream.Write($ResponseBuffer, 0, $ResponseBuffer.Length)                
            }
            $this.HttpResponse.Headers.Add("Content-Type", $this.ContentType)
        } catch {
            $this.HttpResponse.StatusCode = 500
        } finally {
            $this.HttpResponse.OutputStream?.Flush()
            $this.HttpResponse.Close()
            "close response" | Out-File -Append -FilePath "./log.txt"
        }
    }
}