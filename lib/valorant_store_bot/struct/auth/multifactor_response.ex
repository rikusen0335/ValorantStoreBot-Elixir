defmodule Auth.MultifactorResponse do
  @derive Jason.Encoder
  defstruct [
    :type,
    :country,
    :securityProfile,
    multifactor: %{
      email: nil,
      method: nil,
      methods: [],
      multi_factor_code_length: nil,
      mfa_version: nil,
    }
  ]
end
