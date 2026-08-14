package ai

import (
	"beginnerbot/tak"
	"context"
)

type TakPlayer interface {
	GetMove(ctx context.Context, p *tak.Position) tak.Move
}
