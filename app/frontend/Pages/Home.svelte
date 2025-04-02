<script>
  import LogoSvg from "../assets/images/logo.svg?raw";
  import registrationRoutes from "../api/Devise/RegistrationsApi";
  import sessionRoutes from "../api/Devise/SessionsApi";
</script>

<div class="logo">{@html LogoSvg}</div>
<div class="session-links">
  <a href={registrationRoutes.new.path()}>Sign up</a>
  <a href={sessionRoutes.new.path()}>Sign in</a>
</div>
