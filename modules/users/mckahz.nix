{ den, ... }:
{
  den.aspects.mckahz = {
    includes = [
      den.batteries.define-user
      den.batteries.primary-user
    ];

    hjem = {
      user = "mckahz";
      directory = "/home/mckahz";
    };
  };
}
