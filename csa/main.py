import click

from csa.config import setup_params
from csa.csa import test


@click.command()
@click.argument("location")
@click.option("--hl", is_flag=True, default=False, help="Unrestricted walking with hub labelling")
@click.option("-p", "--profile", is_flag=True, default=False, help="Run profile query")
@click.option("-r", "--ranked", is_flag=True, default=False, help="Used ranked queries")
def main(location, hl, profile, ranked):
    print(location, hl, profile, ranked)

    setup_params(location, hl, profile, ranked)

    test()


if __name__ == "__main__":
    main()
