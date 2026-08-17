package ai

import (
	"github.com/USTakAssociation/BeginnerBot/tak"
	"context"
)

type TakPlayer interface {
	GetMove(ctx context.Context, p *tak.Position) tak.Move
}
