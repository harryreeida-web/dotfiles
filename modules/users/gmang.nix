{ den, ... }:
{
  den.aspects.gmang = {
    includes = [
      den.batteries.define-user
      den.batteries.primary-user
    ];

    hjem = {
      user = "gmang";
      directory = "/home/gmang";
    };
  };
}
