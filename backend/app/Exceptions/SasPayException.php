<?php

namespace App\Exceptions;

use Exception;

class SasPayException extends Exception
{
    protected ?int $httpStatus;
    protected ?string $errorCode;
    protected ?array $errorDetails;

    public function __construct(
        string $message = '',
        ?int $httpStatus = null,
        ?string $errorCode = null,
        ?array $errorDetails = null,
        ?\Throwable $previous = null
    ) {
        parent::__construct($message, $httpStatus ?? 0, $previous);
        $this->httpStatus = $httpStatus;
        $this->errorCode = $errorCode;
        $this->errorDetails = $errorDetails;
    }

    public function getHttpStatus(): ?int
    {
        return $this->httpStatus;
    }

    public function getErrorCode(): ?string
    {
        return $this->errorCode;
    }

    public function getErrorDetails(): ?array
    {
        return $this->errorDetails;
    }
}
